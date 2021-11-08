# frozen_string_literal: true

class MailBlacklist < ApplicationRecord
  include FullTextFilter
  include Logging

  validates :pattern, :source, presence: true

  scope :active, -> { where active: true }

  def to_s
    pattern
  end

  private

  def update_full_text
    FullTextContent.find_or_initialize_by(table: self.class.table_name, subject_id: id)
      .update(content: [pattern, source].join(' '))
  end
end
