# frozen_string_literal: true

class AbuseReportsController < ApplicationController
  def create
    return head(:unprocessable_entity) if permitted_params[:message].blank?
    @abuse_report = AbuseReport.create!(permitted_params.merge(author: Current.author))
    @issue = @abuse_report.issue
  end

  def update
    @abuse_report = AbuseReport.find(params[:id])
    @abuse_report.update(resolved_at: Time.current)
  end

  private

  def permitted_params
    params.require(:abuse_report).permit(:issue_id, :message)
  end
end
