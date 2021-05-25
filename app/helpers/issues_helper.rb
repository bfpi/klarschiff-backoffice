# frozen_string_literal: true

module IssuesHelper
  def comment_headline(comment)
    "#{comment}#{"; bearbeitet #{I18n.l(comment.updated_at)}" if comment.created_at.to_i != comment.updated_at.to_i}"
  end

  def description_status_external_title
    "#{Issue.human_attribute_name :description_status}: #{Issue.human_enum_name :description_status, :external}"
  end

  def description_status_internal_title
    "#{Issue.human_attribute_name :description_status}: #{Issue.human_enum_name :description_status, :internal}"
  end

  def status_symbol(status)
    status.to_sym == :external ? 'globe' : 'home'
  end

  def grouped_categories(kind_or_isse)
    kind, category_id = kind_or_isse.is_a?(Issue) ? [kind_or_isse.kind, kind_or_isse.category_id] : [kind_or_isse, nil]
    return [] unless kind
    grouped_options_for_select grouped_categories_for_kind(kind), category_id
  end

  def nav_item(tab, issue, current_tab, issue_or_delegation = :issue)
    css_class = "nav-link #{:active if tab == current_tab}"
    path = send("edit_#{issue_or_delegation}_path", issue, tab: tab)
    tag.li link_to(t("issues.form.tab.#{tab}"), path, remote: true, class: css_class), class: 'nav-item'
  end

  def responsibilities
    [[t('issues.extended_filter.my_responsibility'), 0]] +
      Group.kind_internal.order(:name).map { |gr| [gr.name, gr.id] }
  end

  def delegations
    Group.kind_external.order(:name).map { |gr| [gr.name, gr.id] }
  end

  def field_service_teams
    Group.kind_field_service_team.order(:name).map { |gr| [gr.name, gr.id] }
  end

  def kinds
    [[t('issues.extended_filter.all_kinds'), nil]] + MainCategory.kinds.to_a
      .map { |k| [t("enums.main_category.kind.#{k[0]}"), k[1]] }
  end

  def main_categories(kind = nil)
    [[t('issues.extended_filter.all_main_categories'), nil]] +
      MainCategory.where(kind: kind).order(:name).map { |c| [c.name, c.id] }
  end

  def sub_categories(main_id = nil)
    [[t('issues.extended_filter.all_sub_categories'), nil]] +
      SubCategory.includes(categories: :main_category)
        .where(main_category: { id: main_id }).order(:name).map { |c| [c.name, c.id] }
  end

  def priorities
    Issue.priorities.to_a.map { |k| [t("enums.issue.priority.#{k[0]}"), k[1]] }
  end

  def districts
    [[t('issues.extended_filter.all_districts'), nil]] + District.order(:name).map { |d| [d.name, d.id] }
  end

  def archived_options
    [true, false].map { |val| [t(val), val] }
  end
  
  def external_map_url(issue = @issue)
    (
      Settings::Geoportal.url %
      [issue.lon_external, issue.lat_external, Settings::Geoportal.scale, "Vorgang+#{issue.id}"]
    ).html_safe
  end

  private

  def grouped_categories_for_kind(kind)
    Category.includes(:main_category, :sub_category).where(main_category: { kind: kind }).to_a
      .group_by(&:main_category_name).map do |mc, categories|
      [mc, categories.sort_by(&:sub_category_name).map { |c| [c.sub_category_name, c.id] }]
    end
  end

  def status_note_templates
    (Config.for :status_note_template, env: nil).select { |_k, v| v.present? }
  end
end
