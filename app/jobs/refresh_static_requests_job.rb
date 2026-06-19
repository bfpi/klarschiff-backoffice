# frozen_string_literal: true

require 'net/http'

class RefreshStaticRequestsJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    # Workaround for open-uri https-proxy problem
    if (proxy = ENV['HTTP_PROXY'] || ENV.fetch('http_proxy', nil)).present?
      proxy = "http://#{proxy}" unless %r{^https?://}.match?(proxy)
      p_uri = URI.parse(proxy)
      Net::HTTP.Proxy p_uri.host, p_uri.port
    else
      Net::HTTP
    end.get URI.join(Settings::Instance.frontend_url, 'requests')
  end
end
