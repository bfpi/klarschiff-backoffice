# frozen_string_literal: true

module Citysdk
  module PrivacyPolicy
    extend ActiveSupport::Concern

    def privacy_policy_accepted
      @privacy_policy_accepted
    end

    def privacy_policy_accepted=(value)
      if Settings::Instance.validate_privacy_policy && !value
        errors.add :base, :privacy_policy_not_accepted
        raise ActiveRecord::RecordInvalid, self
      end
      @privacy_policy_accepted = value
    end
  end
end
