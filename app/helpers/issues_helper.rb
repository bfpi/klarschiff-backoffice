# frozen_string_literal: true

module IssuesHelper
  def description_status_external_title
    "#{Issue.human_attribute_name :description_status}: #{Issue.human_enum_name :description_status, :external}"
  end

  def description_status_internal_title
    "#{Issue.human_attribute_name :description_status}: #{Issue.human_enum_name :description_status, :internal}"
  end

  def grouped_categories(kind_or_isse)
    kind, category_id = kind_or_isse.is_a?(Issue) ? [kind_or_isse.kind, kind_or_isse.category_id] : [kind_or_isse, nil]
    return [] unless kind
    grouped_options_for_select grouped_categories_for_kind(kind), category_id
  end

  def nav_item(tab, issue, current_tab)
    css_class = "nav-link #{:active if tab == current_tab}"
    tag.li link_to(t(".tab.#{tab}"), edit_issue_path(issue, tab: tab), remote: true, class: css_class),
      class: 'nav-item'
  end

  private

  def grouped_categories_for_kind(kind)
    Category.includes(:main_category, :sub_category).where(main_category: { kind: kind }).to_a
      .group_by(&:main_category_name).map do |mc, categories|
      [mc, categories.sort_by(&:sub_category_name).map { |c| [c.sub_category_name, c.id] }]
    end
  end
end
