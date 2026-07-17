# frozen_string_literal: true

class Service < Category
  include Citysdk::Serialization

  self.serialization_attributes = %i[service_code service_name description metadata type keywords group]
  alias_attribute :service_name, :sub_category

  private

  def service_code
    id.to_s
  end

  def description; end

  def metadata # rubocop:disable Naming/PredicateMethod
    false
  end

  def type
    'realtime'
  end

  def keywords
    kind || parents.first.kind
  end

  def group
    main_category
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
