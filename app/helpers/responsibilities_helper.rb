# frozen_string_literal: true

module ResponsibilitiesHelper
  def grouped_categories_for_responsibility
    Category.active.order(MainCategory.arel_table[:kind], MainCategory.arel_table[:name])
      .group_by(&:main_category_name_with_kind).map do |mc, categories|
      [mc, categories.sort_by(&:sub_category_name).map { |c| [c.sub_category_name, c.id] }]
    end
  end

  def groups_options(resp_or_category)
    category_id = resp_or_category.is_a?(Responsibility) ? resp_or_category.category_id : resp_or_category
    return [] if category_id.blank?
    groups = Group.authorized.map { |gr| [gr.to_s, gr.id] }
    return groups_options_with_selected(resp_or_category, groups) if resp_or_category.is_a?(Responsibility)
    options_for_select groups
  end

  private

  def groups_options_with_selected(responsibility, groups)
    options = groups
    if (group = responsibility.group)
      options |= [[group.to_s, group.id]]
    end
    options_for_select options, selected: group&.id
  end
end
