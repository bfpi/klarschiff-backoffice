# frozen_string_literal: true

module Citysdk
  class User < ::User
    include Citysdk::Serialization

    self.serialization_attributes = %i[id name email field_service_team]

    def name
      to_s
    end

    def field_service_team
      groups.where(kind: Group.kinds[:field_service_team]).map(&:short_name).join(',')
    end
  end
end
