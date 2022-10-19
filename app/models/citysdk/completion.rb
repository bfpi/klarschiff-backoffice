# frozen_string_literal: true

module Citysdk
  class Completion < ::Completion
    include Citysdk::BecomesIfValid
    include Citysdk::Serialization
    include Citysdk::PrivacyPolicy

    self.serialization_attributes = %i[id]
    alias_attribute :service_request_id, :issue_id
  end
end
