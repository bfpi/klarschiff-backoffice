# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'change password' do
    configure_password_settings(length: 8)
    pw = 'Bfpi2022**Test'
    user = user(:one)
    assert user.update(password: pw, password_confirmation: pw)
  end

  test 'does not change password with missing or incorrect confirmation' do
    configure_password_settings(length: 8)
    pw = 'Bfpi2022**Test'
    user = user(:one)
    assert_not user.update(password: pw, password_confirmation: nil)
    assert_equal [{ error: :blank }], user.errors.details[:password_confirmation]
    assert_not user.update(password: pw, password_confirmation: '')
    assert_equal [{ error: :blank }, { error: :confirmation, attribute: 'Passwort' }],
      user.errors.details[:password_confirmation]
    assert_not user.update(password: pw, password_confirmation: 'test')
    assert_equal [{ error: :confirmation, attribute: 'Passwort' }], user.errors.details[:password_confirmation]
  end

  test 'validate password length' do
    configure_password_settings(length: 8)
    user = user(:one)
    assert_not user.update(password: 'test')
    assert_equal [{ error: :invalid, length: 8, required_characters: '' }], user.errors.details[:password]
    assert user.update(password: 'testtest', password_confirmation: 'testtest')
  end

  test 'validate password lowercase presence' do
    configure_password_settings(length: 4, included_characters: %i[lowercase])
    user = user(:one)
    assert_not user.update(password: 'TEST')
    char_name = I18n.t('password.lowercase')
    assert_equal [{ error: :invalid, length: 4, required_characters: char_name }], user.errors.details[:password]
    assert user.update(password: 'TESt', password_confirmation: 'TESt')
  end

  test 'validate password capital presence' do
    configure_password_settings(length: 4, included_characters: %i[capital])
    user = user(:one)
    assert_not user.update(password: 'test')
    char_name = I18n.t('password.capital')
    assert_equal [{ error: :invalid, length: 4, required_characters: char_name }], user.errors.details[:password]
    assert user.update(password: 'Test', password_confirmation: 'Test')
  end

  test 'validate password number presence' do
    configure_password_settings(length: 4, included_characters: %i[number])
    user = user(:one)
    assert_not user.update(password: 'test')
    char_name = I18n.t('password.number')
    assert_equal [{ error: :invalid, length: 4, required_characters: char_name }], user.errors.details[:password]
    assert user.update(password: 'test0', password_confirmation: 'test0')
  end

  test 'validate password special_character presence' do
    configure_password_settings(length: 4, included_characters: %i[special_character])
    user = user(:one)
    assert_not user.update(password: 'test')
    char_name = I18n.t('password.special_character')
    assert_equal [{ error: :invalid, length: 4, required_characters: char_name }], user.errors.details[:password]
    assert user.update(password: 'test*', password_confirmation: 'test*')
  end

  test 'ensure no password history by default config' do
    configure_password_settings(length: 4)
    user = user(:one)
    assert_nil user.passwords
    assert user.update(password: 'test', password_confirmation: 'test')
    assert_nil user.reload.passwords
  end

  test 'validate password rotation' do
    configure_password_settings(length: 4, history: 5)
    user = user(:one)
    assert_nil user.passwords
    assert user.update(password: 'test', password_confirmation: 'test')
    assert_not_empty user.reload.passwords
    assert_not user.update(password: 'test', password_confirmation: 'test')
    assert_equal [{ error: :taken }], user.errors.details[:password]
  end

  test 'validate password presence' do
    configure_password_settings(length: 4)
    user = user(:one)
    assert_nil user.ldap
    assert_valid user
    user.password_digest = nil
    assert_not user.valid?
    assert_equal [{ error: :blank }], user.errors.details[:password_digest]
    user.ldap = 'CN=test,DC=klarschiff,DC=de'
    assert_valid user
  end

  test 'generate and save uuid if blank' do
    user = user(:two)
    assert_nil user[:uuid]
    assert_predicate user.uuid, :present?
    assert_not user.reload[:uuid].blank?
  end
end
