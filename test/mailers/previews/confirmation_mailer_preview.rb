# frozen_string_literal: true

class ConfirmationMailerPreview < ActionMailer::Preview
  def issue
    ConfirmationMailer.issue(to: 'test@bfpi.de', issue_id: 99_999_999, confirmation_hash: 'sdff-12sd-d43f')
  end

  def supporter
    ConfirmationMailer.supporter(to: 'test@bfpi.de', issue_id: 99_999_999, confirmation_hash: 'sdff-12sd-d43f')
  end

  def abuse_report
    ConfirmationMailer.abuse_report(to: 'test@bfpi.de', issue_id: 99_999_999, confirmation_hash: 'sdff-12sd-d43f')
  end

  def photo
    ConfirmationMailer.photo(to: 'test@bfpi.de', issue_id: 99_999_999, confirmation_hash: 'sdff-12sd-d43f')
  end
end
