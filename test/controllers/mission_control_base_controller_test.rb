# frozen_string_literal: true

require 'test_helper'

class MissionControlBaseControllerTest < ActionDispatch::IntegrationTest
  # https://github.com/rails/mission_control-jobs/issues/216
  setup do
    ActiveJob::QueueAdapters::TestAdapter.define_method(:activating) { [] }
  end

  teardown do
    ActiveJob::QueueAdapters::TestAdapter.remove_method(:activating)
  end

  %i[regional_admin editor].each do |role|
    test "not authorized jobs for #{role}" do
      login username: role
      get '/server_jobs'
      assert_response :forbidden
    end
  end

  test 'authorized jobs for admin' do
    login username: :admin
    get '/server_jobs'
    assert_response :success
  end
end
