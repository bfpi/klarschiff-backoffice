# frozen_string_literal: true

class CompletionsController < ApplicationController
  def update
    @completion = Completion.find(params.expect(:id))
    @completion.reject_with_status_reset = params[:completion][:reject_with_status_reset]&.to_boolean
    @completion.update! permitted_params
    @issue = @completion.issue.reload
  end

  private

  def permitted_params
    params.expect(completion: %i[issue_id notice status])
  end
end
