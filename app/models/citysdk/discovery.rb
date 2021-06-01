# frozen_string_literal: true

module Citysdk
  class Discovery
    include Citysdk::Serialization

    self.serialization_attributes = %i[changeset contact key_service]

    def changeset
      config[:discovery_changeset]
    end

    def contact
      config[:discovery_contact]
    end

    def key_service
      config[:discovery_key_service]
    end

    def endpoints
      config[:discovery_endpoints]
    end

    private

    def serializable_methods(_options)
      ret = []
      ret << :endpoints
      ret
    end
  end
end
