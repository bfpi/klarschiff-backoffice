# frozen_string_literal: true

require 'test_helper'

class DiscoveryControllerTest < ActionDispatch::IntegrationTest
  test 'index' do
    get '/citysdk/discovery.xml'
    doc = Nokogiri::XML(response.parsed_body)
    requests = doc.xpath('/discovery')
    assert requests.count.positive?
  end
end
