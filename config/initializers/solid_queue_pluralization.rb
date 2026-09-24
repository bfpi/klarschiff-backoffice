# frozen_string_literal: true

Rails.application.config.to_prepare do
  SolidQueue::Record.pluralize_table_names = true
end
