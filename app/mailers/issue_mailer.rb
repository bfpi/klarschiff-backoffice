# frozen_string_literal: true

class IssueMailer < ApplicationMailer
  helper :application, :issues

  def issue(issue_email:)
    @issue_email = issue_email
    image_attachments issue_email: issue_email if issue_email.send_photos?
    mail to: issue_email.to_email, bcc: issue_email.from_email
  end

  def in_process(to:, issue:)
    @issue = issue
    mail(to: to, interpolation: { subject: { number: @issue.id } })
  end

  def closed(to:, issue:)
    @issue = issue
    mail(to: to, interpolation: { subject: { number: @issue.id } })
  end

  def delegation(to:, issues:)
    @issues = issues
    mail to: to
  end

  def inform_editorial_staff(to:, issues:, days:)
    @days = days
    @issues = issues
    mail(to: to, interpolation: { subject: { title: Settings::Instance.name } })
  end

  private

  def image_attachments(issue_email:)
    issue_email.issue.photos.each_with_index do |photo, ix|
      blob = photo.file.variant(resize_to_limit: [600, 600]).blob
      attachments["Foto#{ix + 1}#{File.extname(blob.filename.to_s)}"] = {
        mime_type: blob.content_type,
        content: blob.download
      }
    end
  end
end
