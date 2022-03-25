# frozen_string_literal: true

module Citysdk
  module PrivacyPolicy
    extend ActiveSupport::Concern

    included do
      attr_accessor :privacy_policy_accepted

      validates :privacy_policy_accepted, presence: true, if: -> { Settings::Instance.validate_privacy_policy }
    end
  end
end
