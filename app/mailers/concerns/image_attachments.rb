# frozen_string_literal: true

module ImageAttachments
  extend ActiveSupport::Concern

  private

  def image_attachments(issue:)
    issue.photos.each_with_index do |photo, ix|
      blob = photo.file.variant(resize_to_limit: [600, 600]).blob
      attachments["Foto#{ix + 1}#{File.extname(blob.filename.to_s)}"] = {
        mime_type: blob.content_type,
        content: blob.download
      }
    end
  end
end
