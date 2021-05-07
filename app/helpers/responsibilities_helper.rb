# frozen_string_literal: true

module ResponsibilitiesHelper
  def grouped_categories_for_responsibility
    Category.includes(:main_category, :sub_category).order('main_category.kind ASC, main_category.name ASC')
      .group_by(&:main_category_name_with_kind).map do |mc, categories|
      [mc, categories.sort_by(&:sub_category_name).map { |c| [c.sub_category_name, c.id] }]
    end
  end

  def groups_options(resp_or_category)
    category_id = resp_or_category.is_a?(Responsibility) ? resp_or_category.category_id : resp_or_category
    return [] if category_id.blank?
    groups = Group.includes(:responsibilities).references(:responsibilities).where(
      responsibility_cond(category_id)
    ).collect { |gr| [gr.name, gr.id] }
    return groups_options_with_selected(resp_or_category, groups) if resp_or_category.is_a?(Responsibility)
    options_for_select groups
  end

  private

  def groups_options_with_selected(responsibility, groups)
    group = responsibility.group
    options_for_select groups | [[group.name, group.id]], selected: group.id
  end

  def responsibility_cond(category_id)
    rat[:deleted_at].eq(nil).and(rat[:category_id].not_eq(category_id))
  end

  def rat
    Responsibility.arel_table
  end
end
