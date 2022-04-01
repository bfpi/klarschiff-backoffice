# frozen_string_literal: true

module Citysdk
  module BecomesIfValid
    extend ActiveSupport::Concern

    def becomes_if_valid!(target)
      return becomes(target) if valid?
      raise ActiveRecord::RecordInvalid, self
    end
  end
end
