# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :login, :user, :auth_code
end
