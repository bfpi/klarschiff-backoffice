# frozen_string_literal: true

class TestMailer < ApplicationMailer
  def test(to:)
    headers['X-Override-Consolidation'] = true
    mail to: to
  end
end
