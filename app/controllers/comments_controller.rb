# frozen_string_literal: true

class CommentsController < ApplicationController
  def show
    @comment = Comment.find(params.expect(:id))
  end

  def edit
    @comment = Comment.find(params.expect(:id))
  end

  def create
    return head(:unprocessable_content) if permitted_params[:message].blank?
    @comment = Comment.create!(
      permitted_params.merge(user: Current.user, auth_code: Current.user&.auth_code)
    )
    @issue = @comment.issue
  end

  def update
    @comment = Comment.find(params.expect(:id))
    @comment.update!(permitted_params)
    render template: 'comments/show'
  end

  def destroy
    @comment = Comment.find(params.expect(:id))
    @comment.update!(deleted: true)
  end

  private

  def permitted_params
    params.expect(comment: %i[issue_id message])
  end
end
