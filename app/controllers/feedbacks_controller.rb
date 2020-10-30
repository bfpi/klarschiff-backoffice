# frozen_string_literal: true

class FeedbacksController < ApplicationController

  def index
    @feedbacks = Feedback.all.order(created_at: :desc).page(params[:page] || 1).per(params[:per_page] || 20)
  end
end
