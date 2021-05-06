# frozen_string_literal: true

class DelegationsController < ApplicationController
  include Export
  before_action { check_auth :manage_delegations }

  def index
    @status = params[:status].to_i
    @issues = filter(Issue.not_archived.where.not(delegation_id: nil)).order(created_at: :desc)
    respond_to do |format|
      format.html do
        @issues = paginate_issues
        return render :map if params[:show_map] == 'true'
      end
      format.xlsx { xlsx_export }
    end
  end

  private

  def filter(issues)
    return issues.where(status: :in_process) if @status.zero?
    issues.where(status: %i[duplicate not_solvable closed])
  end

  def paginate_issues
    @issues.page(params[:page] || 1).per(params[:per_page] || 20)
  end
end
