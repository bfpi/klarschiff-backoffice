# frozen_string_literal: true

module Citysdk
  class Note < ::Comment
    include Citysdk::BecomesIfValid
    include Citysdk::Serialization
    include Citysdk::PrivacyPolicy

    self.serialization_attributes = %i[id jurisdiction_id comment datetime service_request_id author]
    alias_attribute :service_request_id, :issue_id
    alias_attribute :comment, :message
    alias_attribute :datetime, :created_at

    def jurisdiction_id; end

    def author
      user.to_s
    end

    def author=(value)
      self.user = User.active.find_by(case_insensitive_comparision(:email, value))
    end
  end
end
