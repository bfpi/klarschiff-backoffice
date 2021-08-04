# frozen_string_literal: true

module Citysdk
  class Job < ::Job
    include Citysdk::Serialization

    self.serialization_attributes = %i[id service_request_id date agency_responsible status]

    def agency_responsible
      group
    end

    def agency_responsible=(value)
      self.group = Group.active.kind_field_service_team.find_by(short_name: value) || group
    end

    def service_request_id
      issue.id
    end

    def service_request_id=(value)
      Issue.find(value)
    end
  end
end
