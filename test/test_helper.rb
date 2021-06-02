# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...

    def api_key_invalid
      'abcdefghijklmnopqrstuvwxyz'
    end

    def api_key_frontend
      Client.keys.first
    end

    def api_key_ppc
      Client.keys.last
    end

    def assert_error_messages(doc, code, description)
      error_message = doc.xpath('/error_messages/error_message')
      assert_equal code, error_message.css('code/text()').first.to_s
      assert_match description, error_message.css('description/text()').first.to_s
    end
  end
end
