# frozen_string_literal: true

module Citysdk
  class Vote < ::Supporter
    include Citysdk::BecomesIfValid
    include Citysdk::Serialization
    include Citysdk::PrivacyPolicy

    attr_accessor :author

    self.serialization_attributes = %i[id]
    alias_attribute :service_request_id, :issue_id
  end
end
