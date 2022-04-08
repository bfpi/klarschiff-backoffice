# frozen_string_literal: true

require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  test 'authorized scope' do
    assert_equal Group.ids, Group.authorized(user(:admin)).ids
    assert_empty Group.authorized(user(:editor))
    user = user(:regional_admin)
    groups = user.groups.active.distinct.pluck(:type, :reference_id)
      .map { |(t, r)| Group.where type: t, reference_id: r }.inject(:or)
    assert_equal groups.ids, Group.authorized(user).ids
  end
end
