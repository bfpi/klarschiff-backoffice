# frozen_string_literal: true

require 'test_helper'

class ResponsibilityTest < ActiveSupport::TestCase
  test 'respond_to deleted_at? and deleted' do
    assert_respond_to responsibility(:one), :deleted_at?
    assert_respond_to responsibility(:one), :deleted
  end

  %i[external field_service].each do |group_kind|
    test "validate group kind not #{group_kind}" do
      Current.user = user(:regional_admin)
      resp = Responsibility.new(category: category(:three), group: group(group_kind))
      assert_not resp.valid?
      assert_includes resp.errors.details[:group], { error: :must_be_internal }
    end
  end

  test 'group_kind validation only when group present' do
    resp = Responsibility.new(category: category(:three))
    assert_nil resp.group
    resp.valid?
    assert_not_includes resp.errors.details[:group], { error: :must_be_internal }
  end

  test 'validate foreign group for admin' do
    Current.user = user(:admin)
    resp = Responsibility.new(category: category(:three), group: group(:internal4))
    assert resp.valid?
  end

  test 'validate foreign group for regional_admin' do
    Current.user = user(:regional_admin)
    resp = Responsibility.new(category: category(:three), group: group(:internal4))
    assert_not resp.valid?
    assert_includes resp.errors.details[:group], { error: :authorized }
  end

  test 'validate valid group for regional_admin' do
    Current.user = user(:regional_admin)
    resp = Responsibility.new(category: category(:three), group: group(:internal2))
    assert resp.valid?
  end
end
