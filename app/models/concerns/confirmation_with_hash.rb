# frozen_string_literal: true

module ConfirmationWithHash
  extend ActiveSupport::Concern

  included do
    before_validation :set_confirmation_hash

    validates :confirmation_hash, presence: true, uniqueness: true

    after_create :confirm
  end

  private

  def confirm
    return send_confirmation if Current.user.blank?
    update! confirmed_at: Time.zone.now
  end

  def send_confirmation
    return if respond_to?(:skip_email_notification) && skip_email_notification
    options = { to: author, issue_id: respond_to?(:issue_id) ? issue_id : id, confirmation_hash: }
    ConfirmationMailer.send(self.class.model_name.singular, **options).deliver_later
  end

  def set_confirmation_hash
    self.confirmation_hash ||= SecureRandom.uuid
  end
end
