# frozen_string_literal: true

module Citysdk
  class Photo < ::Photo
    include Citysdk::Serialization

    attr_accessor :media

    self.serialization_attributes = %i[id]
    alias_attribute :service_request_id, :issue_id
  end
end
