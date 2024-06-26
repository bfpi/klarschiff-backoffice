# frozen_string_literal: true

class IssuesController < ApplicationController
  include Export
  include Index

  before_action :set_tab
  before_action(only: :create) { check_auth :create_issue }

  def show
    check_auth(:edit_issue, Issue.find(params[:id]))
    @edit_issue_url = edit_issue_url(params[:id])
    @issues = paginate(results)
    render :index
  end

  def new
    @issue = Issue.new
  end

  def edit
    @issue = Issue.authorized.find(params[:id])
    check_auth(:edit_issue, @issue)
    @issue.responsibility_action = @issue.reviewed_at.blank? ? :recalculation : :accept
    respond_to do |format|
      format.js { prepare_tabs }
      format.html do
        html_response
        render :index
      end
    end
  end

  def create
    @issue = Issue.new(issue_params.merge(status: :received))
    return render :new unless @issue.save
    if close_modal?
      unless authorized?(:edit_issue, @issue)
        session[:success] = I18n.t('issues.foreign_create_success', issue_id: @issue.id, group: @issue.group)
      end
      return redirect_to action: :index
    end
    prepare_tabs
    render :edit
  end

  def update
    @issue = Issue.find(params[:id])
    check_auth(:edit_issue, @issue)
    if @issue.update(issue_params) && close_modal?
      unless authorized?(:edit_issue, @issue)
        session[:success] = I18n.t('issues.foreign_update_success', issue_id: @issue.id, group: @issue.group)
      end
      return render inline: 'location.reload();'
    end
    prepare_tabs
    render :edit
  end

  def set_status
    auth_code = AuthCode.find_by(uuid: params[:auth_code])
    @issue = auth_code.issue
    check_auth(:change_issue_status, @issue)
    @issue.update!(status: params[:status])
  end

  def resend_responsibility
    issue = Issue.find(params[:issue_id])
    check_auth :resend_responsibility, issue
    issue.send :notify_group
  end

  private

  def close_modal?
    params[:save_and_close].present? || !authorized?(:edit_issue, @issue)
  end

  def prepare_tabs
    @tabs = issue_tabs
    @feedbacks = feedbacks(@issue) if @tab == :feedback
    @log_entries = log_entries(@issue) if @tab == :log_entry
  end

  def issue_tabs
    tabs = %i[master_data responsibility job feedback comment abuse_report completion map photo log_entry]
    tabs -= [:job] unless Current.user.authorized?(:jobs)
    tabs -= [:feedback] if @issue.feedbacks.blank?
    tabs -= [:completion] if @issue.completions.blank?
    tabs
  end

  def feedbacks(issue)
    issue.feedbacks.order(created_at: :desc).page(params[:page] || 1).per params[:per_page] || 10
  end

  def log_entries(issue)
    issue.all_log_entries.order(created_at: :desc).page(params[:page] || 1).per params[:per_page] || 10
  end

  def issue_params
    return {} if params[:issue].blank?
    params.require(:issue).permit(*permitted_attributes)
  end

  def permitted_attributes
    attributes = [:address, :archived, :author, :category_id, :delegation_id, :description,
                  :description_status, :expected_closure, :group_id, :new_photo, :parcel, :photo_requested,
                  :position, :priority, :property_owner, :responsibility_action, :status, :status_note,
                  { photos_attributes: permitted_photo_attributes }]
    attributes += %i[job_date job_group_id] if Current.user.authorized?(:jobs)
    attributes
  end

  def permitted_photo_attributes
    %i[id status censor_rectangles censor_width censor_height _modification _destroy]
  end

  def set_tab
    @tab = params[:tab]&.to_sym || :master_data
  end
end
