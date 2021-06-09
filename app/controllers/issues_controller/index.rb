# frozen_string_literal: true

class IssuesController
  module Index
    extend ActiveSupport::Concern

    def index
      check_auth(:issues)
      respond_to do |format|
        format.json { render json: Issue.where(id: params[:ids]).to_json }
        format.js { js_response }
        format.html { html_response }
        format.xlsx { xlsx_response }
      end
    end

    private

    def base_collection
      Issue.authorized.includes(:abuse_reports, :group, :delegation, category: %i[main_category sub_category])
        .order created_at: :desc
    end

    def html_response
      @edit_issue_url = edit_issue_url(Current.user.auth_code.issue_id) if params[:auth_code]
      @issues = paginate(results)
    end

    def xlsx_response
      @issues = results
      xlsx_export
    end

    def js_response
      @issues = paginate(results)
      return render(:map) if params[:show_map] == 'true'
    end

    def results
      @extended_filter = params[:extended_filter] == 'true'
      @status = (params[:status] || 0).to_i
      return base_collection if Current.user.auth_code
      IssueFilter.new(params).collection
    end

    def paginate(issues)
      issues.page(params[:page] || 1).per(params[:per_page] || 20)
    end
  end
end
