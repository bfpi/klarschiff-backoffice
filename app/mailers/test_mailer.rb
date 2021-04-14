# frozen_string_literal: true

class TestMailer < ApplicationMailer
  def test(to:)
    mail to: to
  end
end
