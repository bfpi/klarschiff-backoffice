# frozen_string_literal: true

class CompletionMailer < ApplicationMailer
  def rejection(completion:, to:)
    @completion = completion
    issue = completion.issue
    mail(to:, interpolation: { subject: { number: issue.id } })
  end
end
