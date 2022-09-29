# frozen_string_literal: true

class CompletionsController < ApplicationController
  def update
    @completion = Completion.find(params[:id])
    @completion.reject_with_status_reset = params[:completion][:reject_with_status_reset] == 'true'
    return render(:error) unless @completion.update(permitted_params)
    @issue = @completion.issue.reload
  end

  private

  def permitted_params
    params.require(:completion).permit(:issue_id, :notice, :status)
  end
end
