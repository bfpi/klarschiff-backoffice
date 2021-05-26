# frozen_string_literal: true

class IssueMailer < ApplicationMailer
  include IssuesHelper
  helper :issues

  def issue(issue_email:)
    @issue_email = issue_email
    image_attachments(issue_email: issue_email)
    mail(
      to: issue_email.to_email,
      bcc: issue_email.from_email
    )
  end

  private

  def image_attachments(issue_email:)
    return unless issue_email.send_photos?
    issue_email.issue.photos.each_with_index do |photo, ix|
      blob = photo.file.variant(resize_to_limit: [600, 600]).blob
      attachments["Foto#{ix + 1}#{File.extname(blob.filename.to_s)}"] = {
        mime_type: blob.content_type,
        content: blob.download
      }
    end
  end
end
