# frozen_string_literal: true

class Comment < ApplicationRecord
  include Logging

  belongs_to :issue
  belongs_to :user, optional: true

  validates :message, presence: true

  default_scope { where(deleted: false).order(created_at: :desc) }

  def to_s(skip_seconds: false)
    options = {}
    options[:format] = :no_seconds if skip_seconds
    "#{user} - #{I18n.l created_at, **options}"
  end
end
