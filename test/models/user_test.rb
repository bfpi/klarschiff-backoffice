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
    assert_not user.update(password: pw, password_confirmation: '')
    assert_includes user.errors.details[:password_confirmation], { error: :confirmation, attribute: 'Passwort' }
    assert_not user.update(password: pw, password_confirmation: 'test')
    assert_includes user.errors.details[:password_confirmation], { error: :confirmation, attribute: 'Passwort' }
  end

  test 'validate password length' do
    configure_password_settings(length: 8)
    user = user(:one)
    assert_not user.update(password: 'test')
    assert_includes user.errors.details[:password], { error: :invalid, length: 8, required_characters: '' }
    assert user.update(password: 'testtest')
  end

  test 'validate password lowercase presence' do
    configure_password_settings(length: 4, included_characters: %i[lowercase])
    user = user(:one)
    assert_not user.update(password: 'TEST')
    char_name = I18n.t('password.lowercase')
    assert_includes user.errors.details[:password], { error: :invalid, length: 4, required_characters: char_name }
    assert user.update(password: 'TESt')
  end

  test 'validate password capital presence' do
    configure_password_settings(length: 4, included_characters: %i[capital])
    user = user(:one)
    assert_not user.update(password: 'test')
    char_name = I18n.t('password.capital')
    assert_includes user.errors.details[:password], { error: :invalid, length: 4, required_characters: char_name }
    assert user.update(password: 'Test')
  end

  test 'validate password number presence' do
    configure_password_settings(length: 4, included_characters: %i[number])
    user = user(:one)
    assert_not user.update(password: 'test')
    char_name = I18n.t('password.number')
    assert_includes user.errors.details[:password], { error: :invalid, length: 4, required_characters: char_name }
    assert user.update(password: 'test0')
  end

  test 'validate password special_character presence' do
    configure_password_settings(length: 4, included_characters: %i[special_character])
    user = user(:one)
    assert_not user.update(password: 'test')
    char_name = I18n.t('password.special_character')
    assert_includes user.errors.details[:password], { error: :invalid, length: 4, required_characters: char_name }
    assert user.update(password: 'test*')
  end

  test 'no password history' do
    configure_password_settings(length: 4)
    user = user(:one)
    assert_nil user.passwords
    assert user.update(password: 'test')
    assert_nil user.reload.passwords
  end

  test 'validate password rotation' do
    configure_password_settings(length: 4, history_active: true)
    user = user(:one)
    assert_nil user.passwords
    assert user.update(password: 'test', password_confirmation: 'test')
    assert_not_empty user.reload.passwords
    assert_not user.update(password: 'test', password_confirmation: 'test')
    assert_includes user.errors.details[:password], error: :taken
  end

  private

  def pw_settings
    Settings::Password
  end

  def configure_password_settings(length: nil, included_characters: [], history_active: false)
    pw_settings.redefine_singleton_method(:min_length) { length } if length
    pw_settings.redefine_singleton_method(:password_history_active) { history_active }
    %i[number lowercase capital special_character].each do |c|
      pw_settings.redefine_singleton_method(:"include_#{c}") { c.in?(included_characters) }
    end
  end
end
