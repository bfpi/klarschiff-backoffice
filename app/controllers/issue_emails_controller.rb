# frozen_string_literal: true

class IssueEmailsController < ApplicationController
  def show
    @issue_email = IssueEmail.new
    @issue_email.issue_id = params[:issue_id]
    @issue_email.enable_all
    subject = ApplicationMailer.mailer_config.dig(:issue_mailer, :forward, :subject)
    str = render_to_string(template: 'issue_mailer/issue')
    render plain: "mailto:?subject=#{format(subject, number: @issue_email.issue_id)}&body=#{ERB::Util.url_encode(str)}"
  end

  def new
    @issue_email = IssueEmail.new
    @issue_email.issue_id = params[:issue_id]
    @issue_email.enable_all
    @issue_email.from = Current.user.to_s
    @issue_email.from_email = Current.user.email
    render template: 'issue_emails/new', layout: false
  end

  def create
    @issue_email = IssueEmail.new(permitted_params)
    @issue_email.issue_id = params[:issue_id]
    @issue_email.validate
    return render action: :new if @issue_email.errors.present?

    IssueMailer.issue(issue_email: @issue_email).deliver_now
  end

  private

  def permitted_params
    params[:issue_email]&.permit(:from, :from_email, :to_email, :text, :send_map, :send_photos, :send_comments,
      :send_feedbacks, :send_abuse_reports)
  end
end
