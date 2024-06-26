# frozen_string_literal: true

module Filter
  extend ActiveSupport::Concern

  private

  def filter(collection)
    @filter = params[:filter] || {}
    collection = collection.filter_by_full_text_search(@filter[:text]) if @filter[:text].present?
    filter_excludes(filter_name(collection))
  end

  def filter_excludes(collection)
    return collection unless params[:exclude_ids]
    collection.where.not(id: params[:exclude_ids].split(',').map(&:to_i))
  end

  def filter_include_inactive(collection)
    return collection.active unless @filter[:include_inactive]
    collection
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
