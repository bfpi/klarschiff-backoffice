# frozen_string_literal: true

class CompletionMailer < ApplicationMailer
  def rejection(completion:, to:)
    @completion = completion
    issue = completion.issue
    mail(to:, subject: default_i18n_subject(number: issue.id))
  end
end
