# frozen_string_literal: true

class Category < ApplicationRecord
  include FullTextFilter

  belongs_to :main_category
  belongs_to :sub_category

  with_options dependent: :destroy do
    has_many :issues
    has_many :responsibilities
  end

  delegate :kind, :kind_name, :sub_categories, to: :main_category
  delegate :name, :name_with_kind, to: :main_category, prefix: true
  delegate :name, to: :sub_category, prefix: true
  delegate :dms_link, :name, to: :sub_category, prefix: true

  def self.active
    eager_load(:main_category, :sub_category).where main_category: { deleted: false }, sub_category: { deleted: false }
  end

  def to_s
    [main_category, sub_category].join(' – ')
  end

  def group(lat:, lon:)
    group_ids = responsibilities.regional(lat:, lon:).pluck(:group_id)
    Group.regional(lat:, lon:).where(
      Group.arel_table[:id].in(group_ids).or(Group.arel_table[:reference_default].eq(true))
    ).order(:type, :reference_default).first
  end

  private

  def full_text_content
    [to_s, responsibilities.map { |x| x.group.to_s }].join(' ')
  end
end
