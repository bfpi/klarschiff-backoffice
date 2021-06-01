# frozen_string_literal: true

module Citysdk
  class Service < Category
    include Citysdk::Serialization

    self.serialization_attributes = %i[service_code service_name description metadata type keywords group group_id]

    private

    def service_code
      id.to_s
    end

    def service_name
      sub_category.to_s
    end

    def description; end

    def metadata
      false
    end

    def type
      'realtime'
    end

    def keywords
      kind || parents.first.kind
    end

    def group
      main_category.to_s
    end

    def group_id
      main_category.id
    end

    def document_url
      sub_category_dms
    end

    def serializable_methods(options)
      ret = []
      ret |= [:document_url] if options[:document_url]
      ret
    end
  end
end
