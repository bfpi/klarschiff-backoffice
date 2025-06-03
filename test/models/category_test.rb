# frozen_string_literal: true

require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  test 'scope acvtive contains no soft deleted categories' do
    deleted_category = category(:deleted_at)
    assert_not deleted_category.main_category.deleted?
    assert_not deleted_category.sub_category.deleted?
    assert deleted_category.deleted_at
    assert_not_includes Category.active, deleted_category
    assert deleted_category.update(deleted_at: nil)
    assert_includes Category.active, deleted_category
  end
end
