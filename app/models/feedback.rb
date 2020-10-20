# frozen_string_literal: true

class Feedback < ApplicationRecord
  include Logging

  belongs_to :issue

  validates :author, :message, presence: true
end
