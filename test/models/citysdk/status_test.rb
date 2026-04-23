# frozen_string_literal: true

require 'test_helper'

module Citysdk
  class StatusTest < ActiveSupport::TestCase
    Issue.statuses.each_key do |status|
      test "initialize with backend status '#{status}' creates valid instance" do
        assert_nothing_raised do
          citysdk_status = Citysdk::Status.new(status)
          assert_instance_of Citysdk::Status, citysdk_status
          assert_equal status, citysdk_status.to_backend
        end
      end
    end

    test 'initialize with deleted status returns nil for citysdk and open311' do
      status = Citysdk::Status.new('deleted')
      assert_nil status.to_citysdk
      assert_nil status.to_open311
      assert_equal 'deleted', status.to_backend
    end
  end
end
