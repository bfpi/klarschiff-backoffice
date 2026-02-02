# frozen_string_literal: true

class Issue
  module Getters
    extend ActiveSupport::Concern

    def to_s
      "#{kind_name} ##{id}"
    end

    def lat
      position&.y
    end

    def lon
      position&.x
    end

    def lat_external
      external_position.y
    end

    def lon_external
      external_position.x
    end

    def archived # rubocop:disable Naming/PredicateMethod
      archived_at?
    end

    def closed?
      return false unless status
      CLOSED_STATUSES.include? status.to_sym
    end

    def last_editor
      updated_by_user || updated_by_auth_code
    end

    def forwarded_to_group?
      Current.user.groups.include?(group) && issue_responsibilities.first.group != group
    end
  end
end
