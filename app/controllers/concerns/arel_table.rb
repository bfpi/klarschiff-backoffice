# frozen_string_literal: true

module ArelTable
  extend ActiveSupport::Concern

  private

  Dir['app/models/*.rb'].each do |file_name|
    classes = File.readlines(file_name).filter_map do |line|
      next unless (match_data = /class (.*) < ApplicationRecord$/.match(line))
      match_data[1]
    end
    classes.each do |class_name|
      define_method :"#{class_name.underscore}_arel_table" do
        class_name.constantize.arel_table
      end
    end
  end

  def case_insensitive_comparision(attr, value)
    user_arel_table[attr].lower.eq(value.downcase)
  end
end
