# frozen_string_literal: true

class Issue
  module Validations
    extend ActiveSupport::Concern

    included do
      validates :author, presence: true, on: :create
      validates :author, email: true, on: :create
      validates :confirmation_hash, uniqueness: true
      validates :description, :position, :status, presence: true
      validates :status_note, presence: true, if: :expected_closure_changed?
      validates :status_note, presence: true, if: lambda {
                                                    status_changed? && status.to_i > Issue.statuses[:reviewed]
                                                  }, on: :update

      validate :author_blacklist

      before_validation :add_photo
      before_validation :set_confirmation_hash, on: :create
      before_validation :update_address_parcel_property_owner, if: :position_changed?
      before_validation :reset_archived, if: -> { status_changed? && CLOSED_STATUSES.exclude?(status) }
      before_validation :set_responsibility
      before_validation :set_reviewed, on: :update
      before_save :set_expected_closure, if: :status_changed?
    end

    private

    def author_blacklist
      return if errors[:author].present?
      return unless MailBlacklist.exists? pattern: [author, author[author.index('@') + 1..]]
      errors.add :author, :blacklist_pattern
    end

    def add_photo
      return if new_photo.blank?
      photos.new file: new_photo, author: Current.user.to_s, status: :internal
    end

    def set_confirmation_hash
      self.confirmation_hash = SecureRandom.uuid
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
      case responsibility_action&.to_sym
      when :accept
        self.responsibility_accepted = true
      when :manual
        self.responsibility_accepted = false
      else
        self.group = category&.group
        self.responsibility_accepted = false
      end
    end

    def set_reviewed
      return if reviewed_at.present?
      self.reviewed_at = Time.current
      status_reviewed!
    end

    def set_expected_closure
      self.expected_closure = status_in_process? ? Time.zone.today + category.average_turnaround_time.days : nil
    end
  end
end
