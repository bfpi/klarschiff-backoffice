# frozen_string_literal: true

class LogEntriesController < ApplicationController
  include Sorting
  before_action { check_auth :list_log_entries }

  def index
    @log_entries = LogEntry.includes(:auth_code, :user).joins(:user).order(order_attr)
      .page(params[:page] || 1).per(params[:per_page] || 20)
  end

  def custom_order(col, dir)
    case col.to_sym
    when :user
      [User.arel_table[:last_name].send(dir), User.arel_table[:first_name].send(dir)]
    end
  end

  def default_order
    { created_at: :desc }
  end
end
