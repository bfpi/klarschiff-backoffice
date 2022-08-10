# frozen_string_literal: true

class ResponsibilityMailerPreview < ActionMailer::Preview
  def issue
    ResponsibilityMailer.issue Issue.first, to: 'test@bfpi.de', auth_code: AuthCode.new(uuid: SecureRandom.uuid)
  end

  def default_group_without_gui_access
    ResponsibilityMailer.default_group_without_gui_access Issue.first, to: 'test@bfpi.de',
      auth_code: AuthCode.new(uuid: SecureRandom.uuid)
  end

  def remind_group
    issues = Issue.where(responsibility_accepted: false).where.not(group_id: nil).limit(5)
    ResponsibilityMailer.remind_group Group.first, to: %w[test1@bfpi.de test2@bfpi.de], issues:
  end
end
