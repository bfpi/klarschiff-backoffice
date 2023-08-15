# frozen_string_literal: true

module Citysdk
  class RequestFilter
    attr_reader :collection

    def initialize(params = {}, tips:)
      @collection = Citysdk::Request.authorized(tips:).includes(includes).references(includes).eager_load(
        :external_photos, :supporters
      )
      filter_collection(params)
    end

    def includes
      [:group, :delegation, :job, :photos, { category: %i[main_category sub_category] }]
    end

    def filter_collection(params)
      default_filter_abuse_reports(params)
      default_filter_status(params)
      default_filter_area(params)

      params.each do |key, value|
        send("filter_#{key}", params) if respond_to?("filter_#{key}", true) && value.present?
      end
      @collection = @collection.not_status_deleted
      @collection = @collection.not_archived if params[:also_archived].blank? || params[:also_archived] == 'false'
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
      @collection = @collection.where(<<~SQL.squish, lat:, long:, radius: radius.to_f / 100_000)
        (#{Issue.quoted_table_name}."position" &&
          ST_Buffer(ST_SetSRID(ST_MakePoint(:lat, :long), 4326), :radius))
      SQL
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

    def filter_keyword(params)
      @collection = @collection.where(main_category: { kind: (params[:keyword] || '').split(/, ?/) })
    end

    def filter_start_date(params)
      @collection = @collection.where(Issue.arel_table[:created_at].gteq(DateTime.parse(params[:start_date])))
    end

    def filter_end_date(params)
      @collection = @collection.where(Issue.arel_table[:created_at].lteq(DateTime.parse(params[:end_date])))
    end

    def filter_updated_after(_params)
      @collection = @collection.where(Issue.arel_table[:updated_at].gteq(DateTime.parse(params[:updated_after])))
    end

    def filter_updated_before(_params)
      @collection = @collection.where(Issue.arel_table[:updated_at].lteq(DateTime.parse(params[:updated_before])))
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
      return @collection = @collection.none unless obs
      @collection = @collection.where(category_id: obs.category_ids.split(',').map(&:to_i))
      @collection = @collection.where(<<~SQL.squish)
        (#{Issue.quoted_table_name}."position" &&
          (#{Observation.where(key: params[:observation_key]).select(:area).to_sql}))
      SQL
    end

    def filter_area_code(params)
      @collection = @collection.where(<<~SQL.squish)
        (#{Issue.quoted_table_name}."position" &&
          (#{Settings.area_level.where(id: params[:area_code].to_i).select(:area).to_sql}))
      SQL
    end

    def filter_with_picture(_params)
      @collection = @collection.where(photo: { status: :external }).order(created_at: :desc)
    end
  end
end
