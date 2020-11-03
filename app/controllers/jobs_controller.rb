# frozen_string_literal: true

class JobsController < ApplicationController
  def index
    @date = params[:date].present? ? Date.new(params[:date]) : Date.current + 2.days
    @grouped_jobs = Job.group_by_group(@date)
  end
end
