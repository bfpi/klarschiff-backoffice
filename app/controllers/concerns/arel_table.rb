# frozen_string_literal: true

module ArelTable
  extend ActiveSupport::Concern

  included do
    private

    ActiveRecord::Base.connection.tables.each do |table|
      define_method "#{table}_arel_table" do
        table.camelize.constantize.arel_table
      end
    end
  end
end
