# frozen_string_literal: true

require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  test 'validate no_associated_categories' do
    group = group(:one)
    assert_valid group
    group.active = false
    assert_not group.valid?
    assert_equal [{ error: :associated_categories }], group.errors.details[:base]
  end

  test 'deactivate group without associated categories' do
    group = group(:external)
    assert_valid group
    assert group.update(active: false)
    assert_not group.reload.active
  end

  test 'authorized scope' do
    assert_equal Group.ids, Group.authorized(user(:admin)).ids
    assert_empty Group.authorized(user(:editor))
    user = user(:regional_admin)
    groups = user.groups.active.distinct.pluck(:type, :reference_id)
      .map { |(t, r)| Group.where type: t, reference_id: r }.inject(:or)
    assert_equal groups.ids, Group.authorized(user).ids
  end

  test 'create with valid attributes' do
    group = Group.new(active: true, type: 'AuthorityGroup', kind: :internal, name: 'test123',
      email: 'test123@example.com', authority: authority(:one))
    assert_predicate group, :valid?
  end

  test 'create with missing required name attribute' do
    group = Group.new(active: true, type: 'AuthorityGroup', kind: :internal)
    assert_not group.valid?
    assert_equal [{ error: :blank }], group.errors.details[:name]
    group.name = 'abc'
    group.valid?
    assert_empty group.errors.details[:name]
  end

  test 'create with missing required email attribute' do
    group = Group.new(active: true, type: 'AuthorityGroup', kind: :internal)
    assert_not group.valid?
    assert_equal [{ error: :blank }], group.errors.details[:email]
    group.email = 'abc@def.com'
    group.valid?
    assert_empty group.errors.details[:email]
  end

  test 'create with missing required authority attribute' do
    group = Group.new(active: true, type: 'AuthorityGroup', kind: :internal)
    assert_not group.valid?
    assert_equal [{ error: :blank }], group.errors.details[:authority]
    group.authority = authority(:one)
    group.valid?
    assert_empty group.errors.details[:authority]
  end

  test 'create with missing required county attribute' do
    group = Group.new(active: true, type: 'CountyGroup', kind: :internal)
    assert_not group.valid?
    assert_equal [{ error: :blank }], group.errors.details[:county]
    group.county = county(:one)
    group.valid?
    assert_empty group.errors.details[:county]
  end

  test 'create with missing required instance attribute' do
    group = Group.new(active: true, type: 'InstanceGroup', kind: :internal)
    assert_not group.valid?
    assert_equal [{ error: :blank }], group.errors.details[:instance]
    group.instance = instance(:mv)
    group.valid?
    assert_empty group.errors.details[:instance]
  end
end
