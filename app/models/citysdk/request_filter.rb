# frozen_string_literal: true

module Citysdk
  class RequestFilter
    attr_reader :collection

    def initialize(params = {})
      @collection = Citysdk::Request.includes(includes).references(includes)
        .select('issue.*, count(supporter.id) as supporter_count')
        .joins('LEFT JOIN supporter ON supporter.issue_id = issue.id')
        .group(group_by)
      filter_collection(params)
    end

    def includes
      [:group, :delegation, :job, :photos, { category: %i[main_category sub_category] }]
    end

    def group_by
      [
        Category.arel_table[:id],
        'delegation_issue.id',
        Group.arel_table[:id],
        Issue.arel_table[:id],
        Job.arel_table[:id],
        MainCategory.arel_table[:id],
        Photo.arel_table[:id],
        SubCategory.arel_table[:id]
      ]
    end

    def filter_collection(params)
      default_filter_abuse_reports(params)
      default_filter_status(params)
      default_filter_area(params)

      params.each do |key, value|
        send("filter_#{key}", params) if respond_to?("filter_#{key}", true) && value.present?
      end
      @collection = @collection.not_status_deleted
      @collection = @collection.not_archived if params[:also_archived].blank?
      limit_requests(params)
    end

    def limit_requests(params)
      return @collection if params[:max_requests].blank?
      @collection = @collection.limit(params[:max_requests].to_i)
    end

    def default_filter_abuse_reports(_params)
      @collection = @collection.where.not(id: AbuseReport.where(resolved_at: nil).select(:issue_id))
    end

    def default_filter_status(params)
      return if params[:status].blank?
      @collection = @collection.where({ status: Citysdk::Status
        .open311_for_backoffice(params[:status] ? params[:status].split(/, ?/) : 'open') })
    end

    def default_filter_area(params)
      return if (lat = params[:lat]).blank? || (long = params[:long]).blank? || (radius = params[:radius]).blank?
      @collection = @collection.where('ST_Within(issue.position, '\
        'ST_Buffer(ST_SetSRID(ST_MakePoint(:lat, :long), 4326), :radius))',
        { lat: lat, long: long, radius: radius.to_f / 100_000 })
    end

    def filter_service_request_id(params)
      @collection = @collection.where(id: params[:service_request_id].split(',').map(&:to_i))
    end

    def filter_service_code(params)
      @collection = @collection.where(category_id: params[:service_code].to_i)
    end

    def filter_detailed_status(params)
      @collection = @collection.where(status:
        Citysdk::Status.citysdk_for_backoffice(params[:detailed_status].split(/, ?/)).presence || '')
    end

    def filter_start_date(params)
      @collection = @collection.where("#{Issue.table_name}.created_at >= ?", DateTime.parse(params[:start_date]))
    end

    def filter_end_date(params)
      @collection = @collection.where("#{Issue.table_name}.created_at <= ?", DateTime.parse(params[:end_date]))
    end

    def filter_updated_after(_params)
      @collection = @collection.where("#{Issue.table_name}.updated_at >= ?", DateTime.parse(params[:updated_after]))
    end

    def filter_updated_before(_params)
      @collection = @collection.where("#{Issue.table_name}.updated_at <= ?", DateTime.parse(params[:updated_before]))
    end

    def filter_agency_responsible(params)
      condition = { id: Issue.joins(job: :group).where(job: { group: { short_name: params[:agency_responsible] } })
        .where(job: { date: Time.zone.today }) }
      @collection = if params[:negation] == 'agency_responsible'
                      @collection.where.not(condition)
                    else
                      @collection.where(condition)
                    end.order(priority: :asc)
    end

    def filter_observation_key(params)
      obs = Observation.find_by(key: params[:observation_key])
      @collection = @collection.where(category_id: obs.category_ids.split(',').map(&:to_i))
      @collection = @collection.where("ST_Within(#{Issue.table_name}.position,"\
        "(select o.area from #{Observation.table_name} o where o.key = ?))",
        params[:observation_key])
    end

    def filter_area_code(params)
      @collection = @collection.where("ST_Within(#{Issue.table_name}.position,"\
        "(select d.area from #{District.table_name} d where d.id = ?))",
        params[:area_code].to_i)
    end

    def filter_with_picture(_params)
      @collection = @collection.where(photo: { status: Photo.statuses[:external] })
    end
  end
end
