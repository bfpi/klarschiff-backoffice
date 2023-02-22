# frozen_string_literal: true

class IssuesRssController < ApplicationController
  include Sorting

  def index
    @issues = IssueFilter.new(true, order_attr, { statuses: (1..6).to_a }).collection
  end
end
