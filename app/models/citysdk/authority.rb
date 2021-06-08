# frozen_string_literal: true

module Citysdk
  class Authority < ::Authority
    include Citysdk::Serialization

    self.serialization_attributes = %i[id name grenze]

    alias_attribute :grenze, :area
  end
end
