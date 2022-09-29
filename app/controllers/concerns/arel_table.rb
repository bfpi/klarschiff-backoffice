# frozen_string_literal: true

module ArelTable
  extend ActiveSupport::Concern

  private

  Dir['app/models/**/*.rb'].each do |table|
    table.sub!('app/models/', '').sub!('.rb', '').tr!('/', '_')
    define_method "#{table}_arel_table" do
      table.camelize.constantize.arel_table
    end
  end
end
