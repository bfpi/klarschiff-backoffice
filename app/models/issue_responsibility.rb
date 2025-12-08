# frozen_string_literal: true

class IssueResponsibility < ApplicationRecord
  belongs_to :issue
  belongs_to :group
end
