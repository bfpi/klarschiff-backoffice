# frozen_string_literal: true

class Issue
  module Setters
    extend ActiveSupport::Concern

    private

    def reset_archived
      self.archived_at = nil
    end

    def set_responsibility?
      !(group.present? && responsibility_action.blank?)
    end

    def set_responsibility
      return responsibility_recalculate! if group.blank?
      send :"responsibility_#{responsibility_action}!" if respond_to?(:"responsibility_#{responsibility_action}!", true)
    ensure
      self.responsibility_already_set = true
      self.responsibility_action = :accept
    end

    def responsibility_recalculate!
      self.group = category&.group(lat:, lon:) || group
      self.responsibility_accepted = group_id == group_id_was
    end

    def responsibility_accept!
      self.responsibility_accepted = true
    end

    def responsibility_reject!
      self.responsibility_accepted = false
    end

    def responsibility_close_as_not_solvable!
      assign_attributes(
        responsibility_accepted: false, status: 'not_solvable',
        status_note: Config.for(:status_note_template, env: nil)['Zuständigkeit']
      )
    end

    def responsibility_manual!
      return if group_id == group_id_was
      self.responsibility_accepted = false
    end

    def set_reviewed_at
      return if status.in? %w[pending received]
      self.reviewed_at ||= Time.current
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
  end
end
