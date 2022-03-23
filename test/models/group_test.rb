# frozen_string_literal: true

require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  test 'authorized scope' do
    Current.user = user(:admin)
    assert_equal Group.count, Group.authorized.count
    Current.user = user(:editor)
    assert_empty Group.authorized
    Current.user = user(:regional_admin)
    groups = Current.user.groups.active.distinct.pluck(:type, :reference_id)
      .map { |(t, r)| Group.where type: t, reference_id: r }.inject :or
    assert_equal groups.count, Group.authorized.count
  end
end
