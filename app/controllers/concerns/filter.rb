# frozen_string_literal: true

module Filter
  extend ActiveSupport::Concern

  def filter(collection)
    filter_excludes(filter_name(collection))
  end

  def filter_excludes(collection)
    return collection unless params[:exclude_ids]
    collection.where.not(id: params[:exclude_ids].split(',').map(&:to_i))
  end

  def filter_name(collection)
    return collection if params[:term].blank?
    collection.where name_conditions(params[:term])
  end

  def name_conditions(names)
    names.split(/\s/).select(&:presence).map do |name|
      term = "%#{name}%"
      filter_name_columns.map { |c| arel_table[c].matches term }.inject(:or)
    end.inject(:and)
  end

  def arel_table
    controller_name.classify.constantize.arel_table
  end
end
