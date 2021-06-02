# frozen_string_literal: true

module Citysdk
  class Abuse < ::AbuseReport
    include Citysdk::Serialization

    self.serialization_attributes = %i[id]
    alias_attribute :service_request_id, :issue_id
    alias_attribute :comment, :message

    def privacy_policy_accepted=(value); end
  end
end
