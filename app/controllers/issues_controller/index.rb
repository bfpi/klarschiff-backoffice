# frozen_string_literal: true

class IssuesController
  module Index
    extend ActiveSupport::Concern
    include Sorting

    def index
      check_auth(:issues)
      @success = session.delete(:success)
      respond_to do |format|
        format.json { json_response }
        format.js { js_response }
        format.html { html_response }
        format.xlsx { xlsx_response }
      end
    end

    private

    def json_response
      render json: results.to_json
    end

    def js_response
      @issues = paginate(results)
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
      IssueFilter.new(@extended_filter, order_attr, @filter).collection
    end

    def paginate(issues)
      issues.page(params[:page] || 1).per(params[:per_page] || 20)
    end

    def filter_params
      params.fetch(:filter, {}).permit(*permitted_filter_attributes)
    end

    def permitted_filter_attributes
      [:archived, :author, :begin_at, :delegation, { districts: [] }, :end_at, :kind, :main_category,
       :number, :priority, :responsibility, :status, { statuses: [] }, :sub_category, :supported, :text,
       :updated_by_user, { only_number: [] }]
    end

    def custom_order(col, dir)
      case col.to_sym
      when :category
        [sub_category_arel_table[:name].send(dir)]
      when :group
        [group_arel_table[:name].send(dir)]
      when :last_editor
        custom_order_last_editor(dir)
      when :supporter
        ["COUNT(\"supporter\".\"id\") #{dir}"]
      end
    end

    def custom_order_last_editor(dir)
      [Arel.sql("CASE
          WHEN updated_by_user_id is not null then
            (select concat(last_name, ', ', first_name) from \"#{user_arel_table.name}\" u
              where u.id = updated_by_user_id)
          WHEN updated_by_auth_code_id is not null then
            (select short_name from \"#{group_arel_table.name}\" g
              where g.id in (select group_id from auth_code where id = updated_by_auth_code_id)) END #{dir}")]
    end

    def default_order
      { created_at: :desc }
    end
  end
end
