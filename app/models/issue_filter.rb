# frozen_string_literal: true

class IssueFilter
  include ExtendedFilter

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
end
