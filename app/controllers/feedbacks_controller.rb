# frozen_string_literal: true

class FeedbacksController < ApplicationController
  before_action { check_auth :manage_feedbacks }

  def index
    @feedbacks = Feedback.all.order(created_at: :desc).page(params[:page] || 1).per(params[:per_page] || 20)
  end
end
