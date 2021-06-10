# frozen_string_literal: true

class DelegationsController < ApplicationController
  include DelegationsController::Export

  before_action :set_status, :set_tab

  def index
    check_auth :delegations
    respond_to do |format|
      format.json { render json: issues.to_json }
      format.html { html_response }
      format.xlsx { xlsx_export paginate(issues) }
    end
  end

  def show
    check_auth :edit_delegation, Issue.find(params[:id])
    @edit_delegation_url = edit_delegation_url(params[:id])
    @issues = paginate(issues)
    render :index
  end

  def edit
    @issue = Issue.find(params[:id])
    check_auth :edit_delegation, @issue
  end

  def update
    @issue = Issue.find(params[:id])
    check_auth :edit_delegation, @issue
    return reject if params[:reject].present?
    if @issue.update(issue_params) && params[:save_and_close].present?
      redirect_to delegations_url(filter: { status: @status })
    else
      render :edit
    end
  end

  private

  def issues
    issues = Issue.authorized.includes(category: %i[main_category sub_category])
      .not_archived.where.not(delegation_id: nil).order(created_at: :desc)
    return issues if Current.user.auth_code
    return issues.status_in_process if @status.zero?
    issues.where(status: %i[duplicate not_solvable closed])
  end

  def html_response
    if params[:show_map] == 'true'
      @filter = { status: @status }.to_json
      return render :map
    end
    @edit_issue_url = edit_issue_url(Current.user.auth_code.issue_id) if params[:auth_code]
    @issues = paginate(issues)
  end

  def reject
    @issue.update(delegation_id: nil)
    redirect_to action: :index
  end

  def set_status
    @status = params.fetch(:filter, {})[:status].to_i
  end

  def set_tab
    @tab = params[:tab]&.to_sym || :master_data
  end

  def issue_params
    return {} if params[:issue].blank?
    params.require(:issue).permit(:status, :status_note)
  end

  def paginate(issues)
    issues.page(params[:page] || 1).per(params[:per_page] || 20)
  end
end
