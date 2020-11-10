# frozen_string_literal: true

class JobsController < ApplicationController
  def index
    @date = params[:job_date] || l(Date.current + 2.days)
    @grouped_jobs = Job.includes({ issue: :category }, %i[group]).group_by_user_group(@date)
  end

  def update_statuses
    Job.where(id: params[:job_ids]).update(status: params[:status])
  end

  def destroy
    job = Job.find(params[:id])
    job.destroy!
  end
end
