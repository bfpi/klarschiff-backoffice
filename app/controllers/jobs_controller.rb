# frozen_string_literal: true

class JobsController < ApplicationController
  def index
    return order_jobs if params[:job_ids]
    @date = params[:job_date] || l(Date.current + Settings::Job.lead_time.days)
    @grouped_jobs = Job.includes({ issue: { category: %i[main_category sub_category] } }, %i[group])
      .by_order.group_by_user_group(@date)
  end

  def update_statuses
    jobs = Job.where(id: params[:job_ids])
    date = jobs.first.date
    group = jobs.first.group
    jobs.update params.require(:job).permit(:status)
    @jobs = Job.includes({ issue: :category }, %i[group]).where(group: group, date: date).by_order
    render :reload
  end

  def update_dates
    jobs = Job.where(id: params[:job_ids])
    date = jobs.first.date
    group = jobs.first.group
    jobs.update params.require(:job).permit(:date)
    reload_all(date, group)
  end

  def change_order
    job_ids = []
    params[:jobs].each do |_, job|
      job_ids << job.keys[0]
      Job.find(job.keys[0]).update(order: job.values[0])
    end
    @jobs = Job.where(id: job_ids).by_order
    render :reload
  end

  def destroy
    job = Job.find(params[:id])
    group = job.group
    date = job.date
    job.destroy!
    reload_all(date, group)
  end

  def assign
    params[:issue_ids].each { |issue_id| assign_issue(Issue.find(issue_id)) }
    redirect_to issues_url
  end

  private

  def assign_issue(issue)
    if issue.job
      issue.job.update!(group_id: params[:group_id], date: params[:date])
    else
      job = Job.create!(group_id: params[:group_id], date: params[:date], status: :unchecked)
      issue.update(job_id: job.id)
    end
  end

  def reload_all(date, group)
    @active_group_id = group.id
    @grouped_jobs = Job.includes({ issue: :category }, %i[group]).by_order.group_by_user_group(date)
    render :reload_all
  end

  def order_jobs
    order_by_created_at(Job.includes(:issue).where(id: params[:job_ids]).order('issue.created_at ASC'))
    @jobs = Job.includes({ issue: :category }, %i[group]).where(id: params[:job_ids]).by_order
    render :reload
  end

  def order_by_created_at(jobs)
    jobs.find_each.with_index do |job, idx|
      job.update(order: idx)
    end
  end
end
