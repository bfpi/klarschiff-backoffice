# frozen_string_literal: true

class CommentsController < ApplicationController
  api!
  def show
    @comment = Comment.find(params[:id])
  end

  def create
    return head(:unprocessable_entity) if permitted_params[:message].blank?
    @comment = Comment.create!(
      permitted_params.merge(user: Current.user, auth_code: Current.user&.auth_code)
    )
    @issue = @comment.issue
  end

  def edit
    @comment = Comment.find(params[:id])
  end

  def update
    @comment = Comment.find(params[:id])
    @comment.update!(permitted_params)
    render template: 'comments/show'
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.update!(deleted: true)
  end

  private

  def permitted_params
    params.require(:comment).permit(:issue_id, :message)
  end
end
