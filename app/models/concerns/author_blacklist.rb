# frozen_string_literal: true

module AuthorBlacklist
  extend ActiveSupport::Concern

  included do
    validate :author_blacklist
  end

  private

  def author_blacklist
    return if errors[:author].present?
    return unless MailBlacklist.active.exists? pattern: [author, author[author.index('@') + 1..]]
    errors.add :author, :blacklist_pattern
  end
end
