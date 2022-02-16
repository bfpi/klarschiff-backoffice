# frozen_string_literal: true

class Issue
  module Callbacks
    extend ActiveSupport::Concern

    include AuthorBlacklist
    include ConfirmationWithHash

    included do
      before_destroy :destroy_dangling_associations

      before_validation :add_photo
      before_validation :update_address_parcel_property_owner, if: :position_changed?
      before_validation :reset_archived, if: -> { status_changed? && CLOSED_STATUSES.exclude?(status) }
      before_validation :set_responsibility
      before_validation :set_reviewed, on: :update, unless: :status_changed?

      before_save :set_expected_closure, if: :status_changed?
      before_save :set_trust_level, if: :author_changed?
      before_save :set_updated_by

      after_save :notify_group,
        if: lambda {
              saved_change_to_status? && status_received? && group_id.present? ||
                saved_change_to_group_id? && !status_pending?
            }

      validates :description, :position, :status, presence: true
      validates :status_note, length: { maximum: Settings::Issue.status_note_max_length }
      validates :status_note, presence: true, if: :expected_closure_changed?
      validates :status_note, presence: true, if: lambda {
                                                    status_changed? && status.to_i > Issue.statuses[:reviewed]
                                                  }, on: :update
    end

    private

    def destroy_dangling_associations
      photos.unscope(where: :confirmed_at).destroy_all
      supporters.unscope(where: :confirmed_at).destroy_all
    end

    def add_photo
      return if new_photo.blank?
      photos.new file: new_photo, author: Current.email, status: :internal
      self.new_photo = nil
    end

    # overwrite ConfirmationWithHash#confirm
    def confirm
      return send_confirmation if Current.user.blank?
      status_received!
    end

    # overwrite ConfirmationWithHash#send_confirmation
    def send_confirmation
      options = { to: author, issue_id: id, confirmation_hash: confirmation_hash }
      options[:photo_confirmation_hash] = photos.first.confirmation_hash if photos.any?
      ConfirmationMailer.issue(**options).deliver_later
    end

    def update_address_parcel_property_owner
      self.address = Geocodr.address(self)
      self.parcel = Geocodr.parcel(self)
      self.property_owner = Geocodr.property_owner(self)
    end

    def reset_archived
      self.archived_at = nil
    end

    def set_responsibility
      return if group.present? && responsibility_action.blank?
      return self.responsibility_accepted = true if responsibility_action_accept?
      return self.responsibility_accepted = false if responsibility_action_reject?
      recalculate_responsibility if recalculate_responsibility?
      self.responsibility_accepted = group_id == group_id_was
    end

    def recalculate_responsibility?
      responsibility_action_recalculate? || responsibility_action.nil?
    end

    def recalculate_responsibility
      self.group = category&.group(lat: lat, lon: lon) || group
    end

    def responsibility_action_accept?
      responsibility_action&.to_sym == :accept
    end

    def responsibility_action_recalculate?
      responsibility_action&.to_sym == :recalculate
    end

    def responsibility_action_reject?
      responsibility_action&.to_sym == :reject
    end

    def set_reviewed
      return if reviewed_at.present?
      self.reviewed_at = Time.current
      status_reviewed!
    end

    def set_expected_closure
      self.expected_closure = status_in_process? ? Time.zone.today + category.average_turnaround_time.days : nil
    end

    def set_trust_level
      self.trust_level = calculate_trust_level
    end

    def set_updated_by
      self.updated_by_user = Current.user
      self.updated_by_auth_code = Current.user&.auth_code
    end

    def calculate_trust_level
      return 0 if (user = User.find_by(User.arel_table[:email].matches(author))).blank?
      return 2 if user.groups.any?(&:kind_field_service_team?)
      1
    end

    def notify_group
      return if group.user_ids.present?
      auth_code = AuthCode.find_or_create_by(issue: self, group: group)
      email = group.email.presence || group.main_user.email
      IssueMailer.responsibility(to: email, issue: self, auth_code: auth_code).deliver_now
    end
  end
end
