class CreateFullTextContent < ActiveRecord::Migration[6.1]
  def change
    create_table :full_text_content do |t|
      t.text :table
      t.bigint :subject_id
      t.text :content

      t.timestamps
    end
  end
end
