# frozen_string_literal: true

require 'test_helper'

class SettingsTest < ActiveSupport::TestCase
  test 'area for main_instance is authority' do
    with_parent_instance_settings do
      assert_equal Citysdk::Authority, Settings.area_level
    end
  end

  test 'area for instance with parent_instance is district' do
    with_parent_instance_settings(url: 'http://www.example.com') do
      assert Citysdk::District, Settings.area_level
    end
  end
end
