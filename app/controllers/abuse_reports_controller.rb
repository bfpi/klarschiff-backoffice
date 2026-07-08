# frozen_string_literal: true

class AbuseReportsController < ApplicationController
  def create
    return head(:unprocessable_content) if permitted_params[:message].blank?
    @abuse_report = AbuseReport.create!(permitted_params.merge(author: Current.author))
    @issue = @abuse_report.issue
  end

  def update
    @abuse_report = AbuseReport.find(params.expect(:id))
    @abuse_report.update(resolved_at: Time.current)
    @issue = @abuse_report.issue.reload
  end

  private

  def permitted_params
    params.expect(abuse_report: %i[issue_id message])
  end
end
