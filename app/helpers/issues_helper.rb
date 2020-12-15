# frozen_string_literal: true

module IssuesHelper
  def nav_item(tab, issue, current_tab)
    css_class = "nav-link #{:active if tab == current_tab}"
    tag.li link_to(t(".tab.#{tab}"), edit_issue_path(issue, tab: tab), remote: true, class: css_class),
      class: 'nav-item'
  end
end
