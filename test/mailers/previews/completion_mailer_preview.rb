# frozen_string_literal: true

class CompletionMailerPreview < ActionMailer::Preview
  def rejection
    CompletionMailer.rejection completion: Completion.new(issue: Issue.first, notice: 'test 1234'), to: 'test@bfpi.de'
  end
end
