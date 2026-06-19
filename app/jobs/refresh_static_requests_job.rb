# frozen_string_literal: true

require 'net/http'

class RefreshStaticRequestsJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    Net::HTTP.get URI.join("#{Settings::Instance.frontend_url}requests")
  end
end
