# frozen_string_literal: true

class Feedback < ApplicationRecord
  include AuthorBlacklist
  include Logging

  belongs_to :issue

  validates :author, :message, presence: true

  default_scope -> { order created_at: :desc }
end
