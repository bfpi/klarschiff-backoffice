# frozen_string_literal: true

class LogEntriesController < ApplicationController
  before_action { check_auth :list_log_entries }

  def index
    @log_entries = LogEntry.order(created_at: :desc).page(params[:page] || 1).per(params[:per_page] || 20)
  end
end
