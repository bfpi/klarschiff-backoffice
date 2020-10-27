# frozen_string_literal: true

class LogEntriesController < ApplicationController
  def index
    @log_entries = LogEntry.order(created_at: :desc).page(params[:page] || 1).per(params[:per_page] || 20)
  end
end
