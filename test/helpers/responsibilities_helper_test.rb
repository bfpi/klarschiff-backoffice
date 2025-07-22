# frozen_string_literal: true

require 'test_helper'

class ResponsibilitiesHelperTest < ActionView::TestCase
  test 'list categories without responsibility for admin' do
    Current.user = user(:admin)

    assert_empty missing_categories
  end

  test 'list categories without responsibility' do
    Current.user = user(:regional_admin2)

    assert_includes missing_categories, category(:three)
  end

  test 'skip categories with given responsibility' do
    Current.user = user(:regional_admin2)

    assert_not_includes missing_categories, category(:one)
  end
end
