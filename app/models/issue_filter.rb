# frozen_string_literal: true

class IssueFilter
  attr_reader :collection

  def initialize(extended_filter, order, params = {})
    @collection = Issue.authorized.includes(includes).references(includes).left_joins(:supporters).group(group_by)
      .order(order)
    params[:only_number].blank? ? filter_collection(params, extended_filter) : filter_number(params)
  end

  private

  def group_by
    [
      Category.arel_table[:id], 'delegation_issue.id', Group.arel_table[:id],
      Issue.arel_table[:id], Job.arel_table[:id], MainCategory.arel_table[:id],
      Photo.arel_table[:id], SubCategory.arel_table[:id], AbuseReport.arel_table[:id]
    ]
  end

  def includes
    [:abuse_reports, :group, :delegation, :job, :photos, { category: %i[main_category sub_category] }]
  end

  def filter_collection(params, extended_filter)
    return extended_filter(params) if extended_filter
    simple_filter params[:status].to_i
  end

  def simple_filter(status)
    @collection =
      case status
      when 0 then @collection.status_open
      when 1 then @collection.status_open.ideas_without_min_supporters
      when 2 then @collection.status_solved
      end
  end

  def extended_filter(params)
    params[:statuses] = Issue.statuses.values if params[:statuses].blank?
    params.each do |key, value|
      send("filter_#{key}", params) if respond_to?("filter_#{key}", true) && value.present?
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

  def filter_district(params)
    district = District.find(params[:district])
    @collection = @collection.where('ST_Contains(?, position)', district.area)
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
