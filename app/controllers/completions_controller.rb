# frozen_string_literal: true

class CompletionsController < ApplicationController
  def edit
    @completion = Completion.find(params[:id])
  end

  def update
    @completion = Completion.find(params[:id])
    @completion.update(permitted_params)
  end

  private

  def permitted_params
    params.require(:completion).permit(:issue_id, :notice, :status)
  end
end
