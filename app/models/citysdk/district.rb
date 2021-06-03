# frozen_string_literal: true

module Citysdk
class District < ::District
  include Citysdk::Serialization

  self.serialization_attributes = %i[id name grenze]

  alias_attribute :grenze, :area
end
end
