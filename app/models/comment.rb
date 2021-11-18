# frozen_string_literal: true

class Comment < ApplicationRecord
  include Logging

  belongs_to :auth_code, optional: true
  belongs_to :issue
  belongs_to :user, optional: true

  validates :message, presence: true
  validate :auth_code_or_user

  default_scope { where(deleted: false).order(created_at: :desc) }

  def to_s(skip_seconds: false)
    options = {}
    options[:format] = :no_seconds if skip_seconds
    "#{auth_code&.group || user}; erstellt #{I18n.l created_at, **options}"
  end

  private

  def auth_code_or_user
    return errors(:auth_code, :blank) if Current.user&.auth_code && auth_code.blank?
    errors.add(:user, :blank) if user_id.blank? && auth_code.blank?
  end
end
