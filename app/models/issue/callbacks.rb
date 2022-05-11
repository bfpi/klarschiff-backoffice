# frozen_string_literal: true

class Issue
  module Callbacks
    extend ActiveSupport::Concern

    include AuthorBlacklist
    include ConfirmationWithHash
    include Setters

    included do
      before_destroy :destroy_dangling_associations

      before_validation :add_photo
      before_validation :update_address_parcel_property_owner, if: :position_changed?
      before_validation :reset_archived, if: -> { status_changed? && CLOSED_STATUSES.exclude?(status) }
      before_validation :set_responsibility
      before_validation :set_reviewed_at, on: :update,
        if: -> { status_changed? && status_reviewed? }, unless: :reviewed_at?

      before_save :clear_group_responsibility_notified_at, if: -> { group_id_changed? && !responsibility_accepted }
      before_save :set_expected_closure, if: :status_changed?
      before_save :set_trust_level, if: :author_changed?
      before_save :set_updated_by, if: -> { Current.user }

      after_save :notify_group,
        if: lambda {
              saved_change_to_status? && status_received? && group_id.present? ||
                saved_change_to_group_id? && !status_pending?
            }

      validate :issue_in_authorized_areas, on: :update
      validates :description, :position, :status, presence: true
      validates :status_note, length: { maximum: Settings::Issue.status_note_max_length }
      validates :status_note, presence: true, if: :expected_closure_changed?
      validates :status_note, presence: true, on: :update,
                              if: -> { status_changed? && status.to_i > Issue.statuses[:reviewed] }
    end

    private

    def destroy_dangling_associations
      photos.unscope(where: :confirmed_at).destroy_all
      supporters.unscope(where: :confirmed_at).destroy_all
    end

    def add_photo
      return if new_photo.blank?
      set_confirmation_hash unless confirmation_hash
      photo = { file: new_photo, author: Current.email, status: :internal }
      if new_record?
        photo[:confirmation_hash] = confirmation_hash
        photo[:skip_email_notification] = true
      end
      photos.new photo
      self.new_photo = nil
    end

    # overwrite ConfirmationWithHash#confirm
    def confirm
      return send_confirmation if Current.user.blank?
      status_received!
    end

    # overwrite ConfirmationWithHash#send_confirmation
    def send_confirmation
      options = { to: author, issue_id: id, confirmation_hash: confirmation_hash, with_photo: photos.any? }
      ConfirmationMailer.issue(**options).deliver_later
    end

    def update_address_parcel_property_owner
      self.address = Geocodr.address(self)
      self.parcel = Geocodr.parcel(self)
      self.property_owner = Geocodr.property_owner(self)
    end

    def calculate_trust_level
      return 0 if (user = User.find_by(User.arel_table[:email].matches(author))).blank?
      return 2 if user.groups.any?(&:kind_field_service_team?)
      1
    end

    def notify_group
      update group_responsibility_notified_at: Time.current
      return if !group.reference_default? && (users = group.users.where(group_responsibility_recipient: true)).blank?
      ResponsibilityMailer.issue(self, **notify_group_options(users)).deliver_later
    end

    def notify_group_options(users)
      if group.reference_default?
        {
          auth_code: AuthCode.find_or_create_by(issue: self, group: group),
          to: group.email.presence || group.main_user.email
        }
      else
        { to: users.map(&:email) }
      end
    end

    def clear_group_responsibility_notified_at
      self.group_responsibility_notified_at = nil
    end

    def issue_in_authorized_areas
      return if Current.user.blank? || Current.user.role_admin?
      errors.add(:position, :outside_of_designated_districts) unless position_within_authorized_areas?
    end

    def position_within_authorized_areas?
      return false unless Current.user
      Current.user.groups.regional(lat: lat, lon: lon).present?
    end
  end
end
