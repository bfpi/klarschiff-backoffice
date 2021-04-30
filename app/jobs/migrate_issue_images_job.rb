# frozen_string_literal: true

class MigrateIssueImagesJob < ApplicationJob
  queue_as :default

  def perform(images_path)
    Dir.glob(File.join(images_path, 'ks_[0-9]*_gross_*.jpg')).each do |image|
      migrate_image(image)
    end
  end

  private

  def migrate_image(image)
    file_name = File.basename(image)
    id = file_name.split('_')[1]
    return print_error(id, file_name) if (issue = Issue.find_by(id: id)).blank?
    photo = issue.photos.new(status: :external)
    photo.file.attach io: File.open(image), filename: file_name, content_type: 'image/jpg'
    photo.save!
  end

  def print_error(issue_id, file_name)
    puts "Meldung ##{issue_id} konnte zu '#{file_name}' nicht gefunden werden." # rubocop: disable Rails/Output
  end
end
