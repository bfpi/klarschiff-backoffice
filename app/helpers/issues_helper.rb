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

  def delegations
    Group.kind_external.map { |gr| [gr.to_s, gr.id, { title: gr.name }] }
  end

  def responsibilities
    Group.kind_internal.map { |gr| [gr.to_s, gr.id, { title: gr.name }] }
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
