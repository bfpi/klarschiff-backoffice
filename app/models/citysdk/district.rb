# frozen_string_literal: true

module Citysdk
  class District < ::District
    include Citysdk::Serialization

    self.serialization_attributes = %i[id name]

    alias_attribute :grenze, :area

    def serializable_methods(options)
      return [] if options[:skip_coordinates]
      [:grenze]
    end
  end
end
