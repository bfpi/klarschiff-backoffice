# frozen_string_literal: true

class Supporter < ApplicationRecord
  include AuthorBlacklist
  include ConfirmationWithHash
  include Logging

  attr_accessor :author

  belongs_to :issue

  after_create :send_confirmation

  private

  def set_confirmation_hash
    self.confirmation_hash ||= Digest::MD5.hexdigest("#{issue.id}#{author}")
      .insert(20, '-').insert(16, '-').insert(12, '-').insert(8, '-')
  end

  def send_confirmation
    ConfirmationMailer.supporter(to: author, issue_id: issue.id, confirmation_hash: confirmation_hash).deliver_later
  end
end
