# frozen_string_literal: true

require 'csv'

class ImportIssueImagesJob < ApplicationJob
  queue_as :default

  def perform(images_csv, images_path)
    CSV.table(images_csv).each do |row|
      if (issue = Issue.find_by(id: row[0])).blank?
        print_error row[0], row[1]
        next
      end
      import_image issue, row, images_path
    end
  end

  private

  def import_image(issue, row, images_path)
    photo = issue.photos.new(status: row[2], author: row[5], confirmation_hash: row[6], confirmed_at: row[7],
      created_at: row[8])
    photo.file.attach io: File.open(Pathname.new(images_path).join(row[1])), filename: row[1], content_type: 'image/jpg'
    photo.save!
  end

  def print_error(issue_id, file_name)
    puts "Meldung ##{issue_id} konnte zu '#{file_name}' nicht gefunden werden." # rubocop: disable Rails/Output
  end
end
