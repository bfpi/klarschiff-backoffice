# frozen_string_literal: true

require 'test_helper'

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test 'rescue from exception and send exception notification' do
    login username: :admin
    original_show = ContactsController.instance_method(:show)
    ContactsController.prepend Override
    email = capture_emails do
      assert_difference 'ActionMailer::Base.deliveries.length' do
        assert_raises RuntimeError do
          get contacts_path
        ensure
          ContactsController.define_method :show, original_show
        end
      end
    end.first
    assert_equal '[KS-Backoffice Exception] contacts#show (RuntimeError) "TestError"', email.subject
  end

  module Override
    def show
      raise 'TestError'
    end
  end
end
