# frozen_string_literal: true

require 'test_helper'

module Citysdk
  class RequestTest < ActiveSupport::TestCase
    test 'scope authorized contains no objects with soft deleted categories' do
      deleted_category = category(:deleted_at)
      assert Request.exists?(category_id: deleted_category.id)
      assert_not Request.authorized(tips: false).exists?(category_id: deleted_category.id)
      assert_not Request.authorized(tips: true).exists?(category_id: deleted_category.id)
    end
  end
end
