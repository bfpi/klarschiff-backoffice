# frozen_string_literal: true

module Citysdk
  class Comment < ::Feedback
    include Citysdk::Serialization
    include Citysdk::PrivacyPolicy

    self.serialization_attributes = %i[id jurisdiction_id author comment datetime service_request_id]
    alias_attribute :service_request_id, :issue_id
    alias_attribute :comment, :message
    alias_attribute :datetime, :created_at

    def jurisdiction_id; end
  end
end
