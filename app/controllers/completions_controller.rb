# frozen_string_literal: true

class CompletionsController < ApplicationController
  def update
    @completion = Completion.find(params[:id])
    @completion.reject_with_status_reset = params[:completion][:status] == 'rejected'
    @completion.update(permitted_params)
  end

  private

  def permitted_params
    params.require(:completion).permit(:issue_id, :notice, :status)
  end
end
