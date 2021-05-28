# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :login, :user
end
