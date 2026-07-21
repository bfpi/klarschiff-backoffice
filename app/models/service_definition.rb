# frozen_string_literal: true

class ServiceDefinition < Category
  include Citysdk::Serialization

  self.serialization_attributes = %i[service_code service_name keywords group]

  alias_attribute :service_code, :id
  alias_attribute :service_name, :sub_category
  alias_attribute :group, :main_category

  def keywords
    kind || main_category.kind
  end

  def document_url
    dms
  end

  def serializable_methods(options)
    ret = []
    ret |= [:document_url] if options[:document_url]
    ret
  end
end
