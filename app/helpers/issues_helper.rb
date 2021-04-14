# frozen_string_literal: true

module IssuesHelper
  def nav_item(tab, issue, current_tab)
    css_class = "nav-link #{:active if tab == current_tab}"
    tag.li link_to(t(".tab.#{tab}"), edit_issue_path(issue, tab: tab), remote: true, class: css_class),
      class: 'nav-item'
  end

  def description_status_external_title
    "#{Issue.human_attribute_name :description_status}: #{Issue.human_enum_name :description_status, :external}"
  end

  def description_status_internal_title
    "#{Issue.human_attribute_name :description_status}: #{Issue.human_enum_name :description_status, :internal}"
  end
end
