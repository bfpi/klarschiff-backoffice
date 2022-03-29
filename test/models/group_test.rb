# frozen_string_literal: true

require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  test 'validate no_associated_categories' do
    group = group(:one)
    assert group.valid?
    group.assign_attributes(active: false)
    assert_not group.valid?
    assert_equal [{ error: :associated_categories }], group.errors.details[:base]
  end

  test 'deactivate group without associated categories' do
    group = group(:external)
    assert group.valid?
    assert group.update(active: false)
    assert_not group.reload.active
  end
end
