# frozen_string_literal: true

module Citysdk
  class ServiceDefinition < Category
    include Citysdk::Serialization

    self.serialization_attributes = %i[service_code service_name keywords group]

    alias_attribute :service_code, :id
    alias_attribute :group, :main_category

    def service_name
      sub_category.to_s
    end

    def keywords
      kind || main_category.kind
    end

    def document_url
      sub_category_dms_link
    end

    def serializable_methods(options)
      ret = []
      ret |= [:document_url] if options[:document_url]
      ret
    end
  end
end
