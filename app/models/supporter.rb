# frozen_string_literal: true

class Supporter < ApplicationRecord
  include Logging

  belongs_to :issue

  validates :confirmation_hash, presence: true, uniqueness: true

  before_validation :set_confirmation_hash, on: :create

  private

  def set_confirmation_hash
    self.confirmation_hash = Digest::MD5.hexdigest("#{issue.id}#{author}")
      .insert(20, '-').insert(16, '-').insert(12, '-').insert(8, '-')
  end
end
