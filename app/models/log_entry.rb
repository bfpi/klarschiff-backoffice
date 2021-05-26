# frozen_string_literal: true

class LogEntry < ApplicationRecord
  belongs_to :auth_code, optional: true
  belongs_to :issue, optional: true
  belongs_to :user, optional: true
end
