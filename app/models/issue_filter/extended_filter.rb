# frozen_string_literal: true

class IssueFilter
  module ExtendedFilter
    extend ActiveSupport::Concern

    private

    def extended_filter(params)
      params[:statuses] = Issue.statuses.values if params[:statuses].blank?
      params.each do |key, value|
        send(:"filter_#{key}", params) if respond_to?(:"filter_#{key}", true) && value.present?
      end
    end

    def filter_text(params)
      @collection = @collection.where(text_conds("%#{params[:text]}%"))
    end

    def filter_number(params)
      @collection = @collection.where(id: params[:only_number] || params[:number])
    end

    def filter_kind(params)
      @collection = @collection.where(main_category: { kind: params[:kind] })
    end

    def filter_main_category(params)
      @collection = @collection.where(main_category: { id: params[:main_category] })
    end

    def filter_sub_category(params)
      @collection = @collection.where(sub_category: { id: params[:sub_category] })
    end

    def filter_author(params)
      @collection = @collection.where(iat[:author].matches("%#{params[:author]}%"))
    end

    def filter_responsibility(params)
      return @collection = @collection.where(group_id: Current.user.group_ids) if params[:responsibility] == '0'
      @collection = @collection.where(group_id: params[:responsibility])
    end

    def filter_delegation(params)
      @collection = @collection.where(delegation_id: params[:delegation])
    end

    def filter_districts(params)
      return if (districts = (params[:districts] || []).select(&:present?)).blank?
      @collection = @collection.where(districts_sql, districts)
    end

    def districts_sql
      <<-SQL.squish
        ST_Within("position", (
          SELECT ST_Multi(ST_CollectionExtract(ST_Polygonize(ST_Boundary("area")), 3))
          FROM #{District.quoted_table_name}
          WHERE "id" IN (?)
        ))
      SQL
    end

    def filter_statuses(params)
      @collection = @collection.where(status: params[:statuses])
    end

    def filter_priority(params)
      @collection = @collection.where(priority: params[:priority])
    end

    def filter_updated_by_user(params)
      @collection = @collection.where(updated_by_user: params[:updated_by_user])
    end

    def filter_archived(params)
      return @collection = @collection.where.not(archived_at: nil) if params[:archived] == 'true'
      @collection = @collection.where(archived_at: nil)
    end

    def filter_supported(_params)
      @collection = @collection.ideas_with_min_supporters
    end

    def filter_begin_at(params)
      @collection = @collection.where(iat[:created_at].gteq(params[:begin_at]))
    end

    def filter_end_at(params)
      @collection = @collection.where(iat[:created_at].lteq(params[:end_at]))
    end

    def text_conds(term)
      iat[:description].matches(term).or(iat[:address].matches(term))
        .or(MainCategory.arel_table[:name].matches(term).or(SubCategory.arel_table[:name].matches(term)))
    end

    def iat
      Issue.arel_table
    end
  end
end
