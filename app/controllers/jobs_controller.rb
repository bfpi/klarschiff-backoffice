# frozen_string_literal: true

class JobsController < ApplicationController
  def index
    @date = params[:job_date] || l(Date.current + 2.days)
    @grouped_jobs = Job.group_by_user_group(@date)
  end
end
