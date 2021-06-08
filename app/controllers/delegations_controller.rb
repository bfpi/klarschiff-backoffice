# frozen_string_literal: true

class DelegationsController < ApplicationController
  include DelegationsController::Export

  before_action :set_status, :set_tab

  def index
    check_auth :delegations
    respond_to do |format|
      format.html { html_response }
      format.xlsx { xlsx_export issues }
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
      redirect_to delegations_url(filter_status: @status)
    else
      render :edit
    end
  end

  private

  def issues
    return auth_code_results if Current.user.auth_code
    issues = Issue.authorized.includes(category: %i[main_category sub_category])
      .not_archived.where.not(delegation_id: nil).order(created_at: :desc)
    return issues.status_in_process if @status.zero?
    issues.where(status: %i[duplicate not_solvable closed])
  end

  def auth_code_results
    Issue.where(id: Current.user.auth_code.issue_id)
  end

  def html_response
    @issues = paginate(issues)
    return render :map if params[:show_map] == 'true'
  end

  def reject
    @issue.update(delegation_id: nil)
    redirect_to action: :index
  end

  def set_status
    @status = params[:filter_status].to_i
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
