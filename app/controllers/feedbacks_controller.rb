# frozen_string_literal: true

class FeedbacksController < ApplicationController
  include Filter
  include Sorting
  before_action { check_auth :manage_feedbacks }

  def index
    @feedbacks = filter(Feedback.all.unscoped).order(order_attr).page(params[:page] || 1).per(params[:per_page] || 20)
  end

  private

  def custom_order(col, dir)
    case col.to_sym
    when :issue
      Feedback.arel_table[:issue_id].send(dir)
    end
  end

  def default_order
    { created_at: :desc }
  end
end
