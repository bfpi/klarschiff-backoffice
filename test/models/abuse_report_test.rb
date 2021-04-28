# frozen_string_literal: true

require 'test_helper'

class AbuseReportTest < ActiveSupport::TestCase
  test 'respond_to resolved_at?' do
    assert_respond_to abuse_report(:one), :resolved_at?
  end
end
