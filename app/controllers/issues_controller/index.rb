# frozen_string_literal: true

class IssuesController
  module Index
    extend ActiveSupport::Concern

    def index
      respond_to do |format|
        format.json { render json: results.to_json }
        format.js { @issues = paginate(results) }
        format.html { html_response }
        format.xlsx { xlsx_response }
      end
    end

    private

    def base_collection
      Issue.includes(:abuse_reports, :group, :delegation, category: %i[main_category sub_category])
        .order created_at: :desc
    end

    def html_response
      return @issues = paginate(results) unless params[:show_map] == 'true'
      @filter = filter_params.presence || { statuses: (1..6).to_a }
      @extended_filter = params[:extended_filter] == 'true'
      render :map
    end

    def xlsx_response
      @issues = results
      xlsx_export
    end

    def results
      @extended_filter = params[:extended_filter] == 'true'
      @filter = filter_params.presence || { statuses: (1..6).to_a }
      @status = (params.fetch(:filter, {})[:status] || 0).to_i
      IssueFilter.new(@extended_filter, @filter).collection
    end

    def paginate(issues)
      issues.page(params[:page] || 1).per(params[:per_page] || 20)
    end

    def filter_params
      params.fetch(:filter, {}).permit(*permitted_filter_attributes)
    end

    def permitted_filter_attributes
      [:archived, :author, :begin_at, :delegation, :district, :end_at, :kind, :main_category,
       :number, :priority, :responsibility, :status, { statuses: [] }, :sub_category, :supported, :text]
    end
  end
end
