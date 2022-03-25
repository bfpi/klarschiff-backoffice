# frozen_string_literal: true

module Citysdk
  class Abuse < ::AbuseReport
    include Citysdk::Serialization
    include Citysdk::PrivacyPolicy

    self.serialization_attributes = %i[id]
    alias_attribute :service_request_id, :issue_id
    alias_attribute :comment, :message
  end
end
