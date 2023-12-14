# frozen_string_literal: true

require 'test_helper'

class ResponsibilityTest < ActiveSupport::TestCase
  test 'respond_to deleted_at? and deleted' do
    assert_respond_to responsibility(:one), :deleted_at?
    assert_respond_to responsibility(:one), :deleted
  end

  %i[external field_service].each do |group_kind|
    test "validate group kind not #{group_kind}" do
      resp = Responsibility.new(category: category(:three), group: group(group_kind))
      assert_not resp.valid?
      assert_equal [{ error: :must_be_internal }], resp.errors.details[:group]
    end
  end
end
