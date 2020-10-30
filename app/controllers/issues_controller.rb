# frozen_string_literal: true

class IssuesController < ApplicationController
  include Filter

  before_action :set_tab

  def overview; end

  def index
    @issues = filter(Issue.all).order(created_at: :desc).page(params[:page] || 1).per(params[:per_page] || 20)
  end

  def edit
    @issue = Issue.find(params[:id])
    return if @tab != :log_entry
    log_entries = @issue.all_log_entries.order(created_at: :desc)
    @log_entries = log_entries.page(params[:page] || 1).per(params[:per_page] || 20)
  end

  def new
    @issue = Issue.new
  end

  def update
    @issue = Issue.find(params[:id])
    if @issue.update(issue_params) && params[:save_and_close].present?
      redirect_to action: :index
    else
      render :edit
    end
  end

  def create
    @issue = Issue.new issue_params
    if @issue.save
      if params[:save_and_close].present?
        redirect_to action: :index
      else
        render :edit
      end
    else
      render :new
    end
  end

  private

  def issue_params
    params.require(:issue).permit(:description, :category_id, :address, :responsibility_id, :delegation_id,
      :author, :status, :kind, :expected_closure, :position)
  end

  def set_tab
    @tab = params[:tab]&.to_sym || :overview
  end
end
