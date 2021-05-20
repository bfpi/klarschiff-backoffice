# frozen_string_literal: true

class Comment < ApplicationRecord
  include Logging

  belongs_to :issue
  belongs_to :user, optional: true

  validates :message, presence: true

  default_scope { where(deleted: false).order(created_at: :desc) }

  def to_s
    "#{user} - #{I18n.l(created_at)}"
  end
end
