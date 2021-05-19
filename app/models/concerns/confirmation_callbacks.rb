# frozen_string_literal: true

module ConfirmationCallbacks
  extend ActiveSupport::Concern

  included do
    after_create :send_confirmation
  end

  private

  def send_confirmation
    return if respond_to?(:skip_email_notification) && skip_email_notification
    ConfirmationMailer.send(
      self.class.model_name.singular,
      { to: author, issue_id: respond_to?(:issue_id) ? issue_id : id, confirmation_hash: confirmation_hash }
    ).deliver_later
  end
end
