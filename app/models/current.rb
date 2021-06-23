# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :email, :login, :user

  def author
    user.auth_code ? user.auth_code.group.feedback_recipient : user.email
  end

  def email
    super.presence || user&.email
  end
end
