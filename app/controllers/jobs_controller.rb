# frozen_string_literal: true

class JobsController < ApplicationController
  def index
    @date = params[:date] || l(Date.current + 2.days)
    @grouped_jobs = Job.group_by_group(@date)
    respond_to do |format|
      format.js
      format.html
    end
  end
end
