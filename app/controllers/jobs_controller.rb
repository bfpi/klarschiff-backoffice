# frozen_string_literal: true

class JobsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :update_multiple

  def index
    return order_jobs if params[:job_ids]
    @date = params[:job_date] || l(Date.current + Settings::Job.lead_time.days)
    @grouped_jobs = Job.includes({ issue: :category }, %i[group]).order('issue.created_at').group_by_user_group(@date)
  end

  def update_multiple
    @jobs = Job.where(id: params[:job_ids])
    @group_id = @jobs.first.group.to_s_html
    @jobs.update params.require(:job).permit(:status, :date)
    render :destroy
  end

  def destroy
    job = Job.find(params[:id])
    group = job.group
    job.destroy!
    @group_id = group.to_s_html
    @jobs = Job.includes({ issue: :category }, %i[group]).where(group_id: group.id, date: params[:date])
  end

  private

  def order_jobs
    @jobs = Job.includes({ issue: :category }, %i[group]).where(id: params[:job_ids])
    @goup_id = @jobs.first.group.to_s_html
    render :destroy
  end
end
