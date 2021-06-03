# frozen_string_literal: true

class IssuesController < ApplicationController
  include Export

  before_action :set_tab

  def index
    respond_to do |format|
      format.json { render json: results.to_json }
      format.js { @issues = paginate(results) }
      format.html { html_response }
      format.xlsx { xlsx_response }
    end
  end

  def show
    @edit_issue_url = edit_issue_url(params[:id])
    @issues = paginate(results)
    render :index
  end

  def edit
    @issue = Issue.authorized.find(params[:id])
    @issue.responsibility_action = @issue.reviewed_at.blank? ? :recalculation : :accept
    prepare_tabs
  end

  def new
    @issue = Issue.new
  end

  def update
    @issue = Issue.find(params[:id])
    return redirect_to action: :index if @issue.update(issue_params) && params[:save_and_close].present?
    prepare_tabs
    render :edit
  end

  def create
    @issue = Issue.new(issue_params.merge(status: :received))
    if @issue.save
      return redirect_to action: :index if params[:save_and_close].present?
      render :edit
    else
      render :new
    end
  end

  private

  def prepare_tabs
    @tabs = issue_tabs
    @feedbacks = feedbacks(@issue) if @tab == :feedback
    @log_entries = log_entries(@issue) if @tab == :log_entry
  end

  def issue_tabs
    tabs = %i[master_data responsibility]
    tabs << :job if Current.user.authorized?(:jobs)
    tabs << :feedback if @issue.feedbacks.any?
    tabs + %i[comment abuse_report map photo log_entry]
  end

  def base_collection
    Issue.includes(:abuse_reports, :group, :delegation, category: %i[main_category sub_category])
      .order created_at: :desc
  end

  def html_response
    return @issues = paginate(results) unless params[:show_map] == 'true'
    @filter = params.permit(*permitted_filter_attributes)
    logger.info "TESTING #{@filter.inspect}"
    @extended_filter = params[:extended_filter] == 'true'
    render :map
  end

  def xlsx_response
    @issues = paginate(results)
    xlsx_export
  end

  def results
    @extended_filter = params[:extended_filter] == 'true'
    @filter = params.permit(*permitted_filter_attributes)
    @status = (params[:status] || 0).to_i
    IssueFilter.new(params).collection
  end

  def feedbacks(issue)
    issue.feedbacks.order(created_at: :desc).page(params[:page] || 1).per params[:per_page] || 10
  end

  def log_entries(issue)
    issue.all_log_entries.order(created_at: :desc).page(params[:page] || 1).per params[:per_page] || 10
  end

  def paginate(issues)
    issues.page(params[:page] || 1).per(params[:per_page] || 20)
  end

  def issue_params
    return {} if params[:issue].blank?
    params.require(:issue).permit(*permitted_attributes)
  end

  def permitted_filter_attributes
    [:archived, :author, :begin_at, :delegation, :district, :end_at, :kind, :main_category,
     :number, :priority, :responsibility, :status, { statuses: [] }, :sub_category, :supported, :text]
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
