# frozen_string_literal: true

class TestMailer < ApplicationMailer
  def test(to:)
    mail to: to, subject: 'Test-Mail'
  end
end
