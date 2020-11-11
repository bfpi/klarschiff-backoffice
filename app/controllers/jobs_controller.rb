# frozen_string_literal: true

class JobsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :update_statuses

  def index
    @date = params[:job_date] || l(Date.current + 2.days)
    @grouped_jobs = Job.includes({ issue: :category }, %i[group]).group_by_user_group(@date)
  end

  def update_statuses
    @jobs = Job.where(id: params[:job_ids])
    @goup_id = @jobs.first.group.name.gsub(' ', '_')
    @jobs.update(status: params[:status])
    render :destroy
  end

  def destroy
    job = Job.find(params[:id])
    group = job.group
    job.destroy!
    @group_id = group.name.gsub(' ', '_')
    @jobs = Job.includes({ issue: :category }, %i[group]).where(group_id: group.id, date: params[:date])
  end
end
