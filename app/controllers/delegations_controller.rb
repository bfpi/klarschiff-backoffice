# frozen_string_literal: true

class DelegationsController < ApplicationController
  include DelegationsController::Export
  include Sorting

  before_action :set_status, :set_tab

  def index
    check_auth :delegations
    respond_to do |format|
      format.json { render json: issues.to_json }
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
    respond_to do |format|
      format.js
      format.html do
        html_response
        render :index
      end
    end
  end

  def update
    @issue = Issue.find(params[:id])
    check_auth :edit_delegation, @issue
    return reject if params[:reject].present?
    if @issue.update(issue_params) && params[:save_and_close].present?
      render inline: 'location.reload();'
    else
      render :edit
    end
  end

  private

  def issues
    issues = Issue.authorized.joins(category: %i[main_category sub_category])
      .not_archived.where.not(delegation_id: nil).order(order_attr)
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
    render inline: 'location.reload();'
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

  def custom_order(col, dir)
    case col.to_sym
    when :category
      [main_category_at[:name].send(dir), sub_category_at[:name].send(dir)]
    end
  end

  def default_order
    { created_at: :desc }
  end
end
