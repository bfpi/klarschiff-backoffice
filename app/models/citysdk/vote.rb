# frozen_string_literal: true

module Citysdk
  class Vote < ::Supporter
    include Citysdk::Serialization

    attr_accessor :author

    self.serialization_attributes = %i[id]
    alias_attribute :service_request_id, :issue_id

    def privacy_policy_accepted=(value); end
  end
end
