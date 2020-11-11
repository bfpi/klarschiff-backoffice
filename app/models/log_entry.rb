# frozen_string_literal: true

class LogEntry < ApplicationRecord
  belongs_to :issue, optional: true
end
