# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :login, :user

  def author
    user.auth_code ? user.auth_code.group.feedback_recipient : user.email
  end
end
