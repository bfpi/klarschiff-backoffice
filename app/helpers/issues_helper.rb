# frozen_string_literal: true

module IssuesHelper
  def comment_headline(comment)
    [comment.to_s(skip_seconds: true)].tap do |a|
      suffix = "bearbeitet #{I18n.l(comment.updated_at, format: :no_seconds)}"
      a << suffix if comment.created_at.to_i != comment.updated_at.to_i
    end.join '; '
  end

  def description_status_external_title
    "#{Issue.human_attribute_name :description_status}: #{Issue.human_enum_name :description_status, :external}"
  end

  def description_status_internal_title
    "#{Issue.human_attribute_name :description_status}: #{Issue.human_enum_name :description_status, :internal}"
  end

  def photo_status_external_title
    "#{Issue.human_attribute_name :photo_approval_status}: #{Photo.human_enum_name :status, :external}"
  end

  def photo_status_internal_title
    "#{Issue.human_attribute_name :photo_approval_status}: #{Photo.human_enum_name :status, :internal}"
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
    css_class = "nav-link switch-tab #{:active if tab == current_tab}"
    path = send(:"edit_#{issue_or_delegation}_path", issue, tab:)
    tag.li link_to(t("issues.form.tab.#{tab}"), '#', data: { url: path }, class: css_class), class: 'nav-item'
  end

  def open_abuse_reports(issue)
    issue.abuse_reports.reject(&:resolved_at?)
  end

  def responsibilities(issue = nil)
    groups = Group.active.kind_internal
    groups = groups.where(id: possible_group_ids(issue)) if issue.present?
    groups.order(:name).map { |gr| [gr.name, gr.id] }
  end

  def delegations(issue = nil)
    groups = Group.active.kind_external
    groups = groups.where(id: possible_group_ids(issue)) if issue.present?
    groups.order(:name).map { |gr| [gr.name, gr.id] }
  end

  def field_service_teams(issue = nil)
    groups = Group.active.kind_field_service_team.where(id: Current.user.field_service_team_ids)
    groups = groups.where(id: possible_group_ids(issue)) if issue.present?
    groups.order(:name).map { |gr| [gr.name, gr.id] }
  end

  def kinds
    [[t('issues.extended_filter.all_kinds'), nil]] + MainCategory.kinds.to_a
      .map { |k| [t("enums.main_category.kind.#{k[0]}"), k[1]] }
  end

  def main_categories(kind)
    [[t('issues.extended_filter.all_main_categories'), nil]] +
      MainCategory.active.where(kind: kind.to_i).order(:name).map { |c| [c.name, c.id] }
  end

  def sub_categories(main_id)
    [[t('issues.extended_filter.all_sub_categories'), nil]] +
      SubCategory.active.includes(categories: :main_category)
        .where(main_category: { id: main_id.to_i }).order(:name).map { |c| [c.name, c.id] }
  end

  def priorities
    Issue.priorities.to_a.map { |k| [t("enums.issue.priority.#{k[0]}"), k[1]] }
  end

  def districts
    [[t('issues.extended_filter.all_districts'), nil]] + District.order(:name).map { |d| [d.name, d.id] }
  end

  def users
    Group.by_user_region.map(&:users).flatten.uniq.sort_by(&:last_name)
  end

  def archived_options
    [true, false].map { |val| [t(val), val] }
  end

  def external_map_url(issue)
    I18n.interpolate Settings::Geoportal.url, lon: issue.lon_external, lat: issue.lat_external,
      scale: Settings::Geoportal.scale, title: "Vorgang+#{issue.id}"
  end

  def kind_and_status_tooltip(issue)
    ["#{MainCategory.human_attribute_name(:kind)}: #{issue.main_category&.human_enum_name(:kind)}",
     "#{Issue.human_attribute_name(:status)}: #{issue.human_enum_name(:status)}"].join(', ')
  end

  def delegation_tooltip(issue)
    "#{Issue.human_attribute_name(:delegation)}: #{issue.delegation.name}"
  end

  private

  def grouped_categories_for_kind(kind)
    Category.active.where(main_category: { kind: })
      .order(MainCategory.arel_table[:name], SubCategory.arel_table[:name])
      .to_a.group_by(&:main_category_name).map do |mc, categories|
      [mc, categories.map { |c| [c.sub_category_name, c.id] }]
    end
  end

  def status_note_templates
    Config.for(:status_note_template, env: nil).select { |_k, v| v.present? }.sort
  end

  def possible_group_ids(issue)
    Group.regional(lat: issue.position.y, lon: issue.position.x).ids
  end
end
