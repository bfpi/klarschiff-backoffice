# frozen_string_literal: true

module Citysdk
  module PrivacyPolicy
    extend ActiveSupport::Concern

    included do
      include ActiveModel::Validations

      attr_accessor :privacy_policy_accepted

      validates :privacy_policy_accepted, acceptance: true, if: -> { Settings::Instance.validate_privacy_policy }
    end
  end
end
