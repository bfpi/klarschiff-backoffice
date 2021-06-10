# frozen_string_literal: true

class JobsController
  module Index
    extend ActiveSupport::Concern

    def index
      respond_to do |format|
        format.html { html_response }
        format.js { order_jobs }
        format.json { json_response }
      end
    end

    private

    def html_response
      return map_view if params[:show_map]
      @active_group_id = params[:active_group_id]
      @date = params[:job_date] || l(Date.current + Settings::Job.lead_time.days)
      @grouped_jobs = Job.includes({ issue: { category: %i[main_category sub_category] } }, %i[group])
        .by_order.group_by_user_group(@date)
    end

    def json_response
      issues = Issue.includes(:job).where(
        job_id: Job.where(group_id: filter_params[:group_id], date: filter_params[:job_date]).select(:id)
      )
      render json: issues.to_json
    end

    def map_view
      @filter = { group_id: params[:group_id], job_date: params[:job_date] }
      render :map
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

    def filter_params
      params.fetch(:filter, {}).permit(:group_id, :job_date)
    end
  end
end
