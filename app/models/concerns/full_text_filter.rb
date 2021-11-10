# frozen_string_literal: true

module FullTextFilter
  extend ActiveSupport::Concern

  included do
    has_one :full_text_content, ->(c) { where(table: c.class.table_name) }, # rubocop:disable Rails/InverseOf
      foreign_key: :subject_id, dependent: :destroy

    after_save_commit :update_full_text
  end

  class_methods do
    def filter_by_full_text_search(pattern)
      where(id: FullTextContent.select(:subject_id).where(table: table_name).where(
        pattern.split.map do |pat|
          FullTextContent.arel_table[:content].matches("%#{pat}%")
        end.inject(&:and)
      ))
    end
  end

  private

  def update_full_text
    FullTextContent.find_or_initialize_by(table: self.class.table_name, subject_id: id)
      .update content: full_text_content
  end

  def full_text_content
    raise '`full_text_content` needs to be defined in model'
  end
end
