# frozen_string_literal: true

class Issue
  module Setters
    extend ActiveSupport::Concern

    private

    def reset_archived
      self.archived_at = nil
    end

    def set_responsibility
      return if group.present? && responsibility_action.blank?
      return close_as_not_solvable if responsibility_action_close?
      return self.responsibility_accepted = true if responsibility_action_accept?
      return self.responsibility_accepted = false if responsibility_action_reject?
      recalculate_responsibility if recalculate_responsibility?
      self.responsibility_accepted = group_id == group_id_was
    end

    def close_as_not_solvable
      assign_attributes(
        responsibility_accepted: false, status: 'not_solvable',
        status_note: Config.for(:status_note_template, env: nil)['Zuständigkeit']
      )
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

    def responsibility_action_close?
      responsibility_action&.to_sym == :close_as_not_solvable
    end

    def set_reviewed_at
      self.reviewed_at = Time.current
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
