# frozen_string_literal: true

class IssueEmail
  include ActiveModel::Model

  attr_accessor :issue_id, :from, :from_email, :to_email, :text, :send_map, :send_photos, :send_comments,
    :send_feedbacks, :send_abuse_reports

  validates :to_email, :text, presence: true
  validates :to_email, email: { if: -> { to_email.present? } }
  validates :from_email, email: { if: -> { from_email.present? } }

  def issue
    @issue ||= Issue.find(issue_id)
  end

  def enable_all
    self.send_map = 1
    self.send_photos = 1
    self.send_comments = 1
    self.send_feedbacks = 1
    self.send_abuse_reports = 1
  end

  %i[map photos comments feedbacks abuse_reports].each do |data|
    define_method :"send_#{data}?" do
      send(:"send_#{data}").to_i == 1
    end
  end
end
