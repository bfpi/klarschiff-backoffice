# frozen_string_literal: true

module Citysdk
  class ServiceDefinition < Category
    include Citysdk::Serialization

    self.serialization_attributes = %i[service_code service_name keywords group]

    private

    def service_code
      id.to_s
    end

    def service_name
      sub_category.to_s
    end

    def keywords
      kind || main_category.kind
    end

    def group
      main_category.to_s
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
