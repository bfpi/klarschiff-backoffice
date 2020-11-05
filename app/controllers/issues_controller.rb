# frozen_string_literal: true

class IssuesController < ApplicationController
  include Filter

  before_action :set_tab

  def index
    @issues = filter(Issue.all).order(created_at: :desc).page(params[:page] || 1).per(params[:per_page] || 20)
  end

  def edit
    @issue = Issue.find(params[:id])
    @issue.responsibility_action = @issue.reviewed_at.blank? ? :recalculation : :accept
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
    @issue = Issue.new issue_params.merge(status: Issue.statuses[:received])
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
    return {} if params[:issue].blank?
    params.require(:issue).permit(:address, :author, :category_id, :delegation_id, :description, :description_status,
      :expected_closure, :kind, :position, :priority, :responsibility_action, :responsibility_id, :status)
  end

  def set_tab
    @tab = params[:tab]&.to_sym || :master_data
  end
end
