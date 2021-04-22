# frozen_string_literal: true

class Comment < ApplicationRecord
  include Logging

  belongs_to :issue
  belongs_to :user, optional: true

  validates :message, presence: true
end
