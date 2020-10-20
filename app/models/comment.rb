# frozen_string_literal: true

class Comment < ApplicationRecord
  include Logging

  belongs_to :issue

  validates :message, presence: true
end
