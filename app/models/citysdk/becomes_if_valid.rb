# frozen_string_literal: true

module Citysdk
  module BecomesIfValid
    extend ActiveSupport::Concern

    def becomes_if_valid!(target)
      raise ActiveRecord::RecordInvalid, self unless valid?
      becomes(target)
    end
  end
end
