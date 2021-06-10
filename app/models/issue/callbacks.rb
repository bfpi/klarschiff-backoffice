# frozen_string_literal: true

class Issue
  module Callbacks
    extend ActiveSupport::Concern

    include AuthorBlacklist
    include ConfirmationWithHash

    included do
      before_validation :add_photo
      before_validation :update_address_parcel_property_owner, if: :position_changed?
      before_validation :reset_archived, if: -> { status_changed? && CLOSED_STATUSES.exclude?(status) }
      before_validation :set_responsibility
      before_validation :set_reviewed, on: :update, unless: :status_changed?
      before_save :set_expected_closure, if: :status_changed?
      before_save :set_trust_level, if: :author_changed?

      validates :description, :position, :status, presence: true
      validates :status_note, presence: true, if: :expected_closure_changed?
      validates :status_note, presence: true, if: lambda {
                                                    status_changed? && status.to_i > Issue.statuses[:reviewed]
                                                  }, on: :update
      validate :position_inside_instance

      after_create :send_confirmation
    end

    private

    def add_photo
      return if new_photo.blank?
      photos.new file: new_photo, author: Current.user.email, status: :internal
    end

    def update_address_parcel_property_owner
      self.address = Geocodr.address(self)
      self.parcel = Geocodr.parcel(self)
      self.property_owner = Geocodr.property_owner(self)
    end

    def position_inside_instance
      return if position.blank?
      cond = 'ST_Within(ST_SetSRID(ST_MakePoint(:lon, :lat), 4326), "area")'
      errors.add :position, :outside_instance unless Instance.exists?([cond, { lat: lat, lon: lon }])
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

    def set_trust_level
      self.trust_level = calculate_trust_level
    end

    def calculate_trust_level
      return 0 if (user = User.find_by(User.arel_table[:email].matches(author))).blank?
      return 2 if user.groups.any?(&:kind_field_service_team?)
      1
    end
  end
end
