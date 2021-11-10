# frozen_string_literal: true

class CreateFullTextContent < ActiveRecord::Migration[6.1]
  def up
    create_table :full_text_content do |t|
      t.text :table
      t.bigint :subject_id
      t.text :content

      t.timestamps
    end
    add_index :full_text_content, %i[table subject_id], unique: true
    FullTextContent.reset_column_information
    initialize_full_text_content
  end

  def down
    drop_table :full_text_content
  end

  private

  def initialize_full_text_content
    [Feedback, Group, MailBlacklist, Responsibility, User].each do |model|
      model.find_each { |o| o.send :update_full_text }
    end
  end
end
