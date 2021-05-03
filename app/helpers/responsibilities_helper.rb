# frozen_string_literal: true

module ResponsibilitiesHelper
  def groups
    Group.all.collect { |group| [group.name, group.id] }
  end

  def categories_options(responsibility)
    return [] if responsibility.group_id.blank?
    category = responsibility.category
    categories = Category.includes(:responsibilities).references(:responsibilities).where(
      responsibility_cond(responsibility.group_id)
    ).collect { |cat| [cat.to_s, cat.id] }
    options_for_select categories | [[category.to_s, category.id]], selected: responsibility.group_id
  end

  private

  def responsibility_cond(group_id)
    rat[:deleted_at].eq(nil).and(rat[:group_id].not_eq(group_id)).or(rat[:id].eq(nil))
  end

  def rat
    Responsibility.arel_table
  end
end
