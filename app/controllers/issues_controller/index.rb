# frozen_string_literal: true

class IssuesController
  module Index
    extend ActiveSupport::Concern
    include Sorting

    def index
      check_auth(:issues)
      respond_to do |format|
        format.json { render json: results.to_json }
        format.js { @issues = paginate(results) }
        format.html { html_response }
        format.xlsx { xlsx_response }
      end
    end

    private

    def base_collection
      Issue.authorized.includes(:abuse_reports, :group, :delegation, category: %i[main_category sub_category])
        .order(order_attr)
    end

    def html_response
      return map_response if params[:show_map] == 'true'
      @edit_issue_url = edit_issue_url(Current.user.auth_code.issue_id) if params[:auth_code]
      @issues = paginate(results)
    end

    def map_response
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
      return base_collection if Current.user.auth_code
      IssueFilter.new(@extended_filter, order_attr, @filter).collection
    end

    def paginate(issues)
      issues.page(params[:page] || 1).per(params[:per_page] || 20)
    end

    def filter_params
      params.fetch(:filter, {}).permit(*permitted_filter_attributes)
    end

    def permitted_filter_attributes
      [:archived, :author, :begin_at, :delegation, :district, :end_at, :kind, :main_category,
       :number, :priority, :responsibility, :status, { statuses: [] }, :sub_category, :supported, :text,
       { only_number: [] }]
    end

    def custom_order(col, dir)
      case col.to_sym
      when :category
        [SubCategory.arel_table[:name].send(dir)]
      when :supporter
        ["COUNT(\"supporter\".\"id\") #{dir}"]
      when :group
        [Group.arel_table[:name].send(dir)]
      end
    end

    def default_order
      { created_at: :desc }
    end
  end
end
