# frozen_string_literal: true

class AuthCode < ApplicationRecord
  belongs_to :issue
  belongs_to :group

  def to_s
    group
  end
end
