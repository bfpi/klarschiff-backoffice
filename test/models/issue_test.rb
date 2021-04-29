# frozen_string_literal: true

require 'test_helper'

class IssueTest < ActiveSupport::TestCase
  test 'respond_to archived_at?' do
    assert_respond_to issue(:one), :archived_at?
  end

  test 'respond_to archived' do
    assert_respond_to issue(:one), :archived
  end

  test 'respond_to reviewed_at?' do
    assert_respond_to issue(:one), :reviewed_at?
  end
end
