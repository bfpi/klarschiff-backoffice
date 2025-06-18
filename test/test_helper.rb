# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/autorun'

module ActiveSupport
  class TestCase
    TEST_ROLES = %i[admin regional_admin editor].freeze

    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...

    def api_key_invalid
      'abcdefghijklmnopqrstuvwxyz'
    end

    def api_key_frontend
      Client.keys.first
    end

    def api_key_ppc
      Client.keys.last
    end

    def login(username: :one, password: 'Bfpi')
      assert user(username)
      post logins_url, params: { login: { login: username, password: } }
      assert_response :redirect
      assert_equal username.to_s, session[:user_login]
    end

    def login_as_ldap_user(username: :one, password: 'Bfpi')
      login(username:, password:)
      user(username).update!(ldap: 'cn=test,ou=klarschiff,ou=HRO,o=EDITOR')
    end

    def assert_privacy_acceptence_validation(doc)
      assert_error_messages doc, '422', 'Gültigkeitsprüfung ist fehlgeschlagen'
      msg = doc.xpath('//description').children[0].content
      assert_match 'Datenschutzbestimmung muss akzeptiert werden', msg
    end

    def assert_error_messages(doc, code, description)
      error_message = doc.xpath('/error_messages/error_message')
      assert_equal code, error_message.css('code/text()').first.to_s
      assert_match description, error_message.css('description/text()').first.to_s
    end

    def assert_valid(object)
      puts "\nUnexpected error(s) on #{object.class}: #{object.errors.full_messages.inspect}" unless object.valid?
      assert_predicate object, :valid?
    end

    def with_parent_instance_settings(url: nil, &block)
      old = Settings::Instance.parent_instance_url
      Settings::Instance.redefine_singleton_method(:parent_instance_url) { url }
      yield if block
      Settings::Instance.redefine_singleton_method(:parent_instance_url) { old }
    end

    def with_privacy_settings(active: false, &block)
      old = Settings::Instance.validate_privacy_policy
      Settings::Instance.redefine_singleton_method(:validate_privacy_policy) { active }
      yield if block
      Settings::Instance.redefine_singleton_method(:validate_privacy_policy) { old }
    end

    def with_gui_access_for_external_participants(value: true, &block)
      old = Settings::Instance.auth_code_gui_access_for_external_participants
      Settings::Instance.redefine_singleton_method(:auth_code_gui_access_for_external_participants) { value }
      yield if block
      Settings::Instance.redefine_singleton_method(:auth_code_gui_access_for_external_participants) { old }
    end

    def configure_password_settings(length: nil, included_characters: [], history: 0)
      PasswordValidator.min_length = length if length
      Settings::Password.redefine_singleton_method(:password_history) { history }
      %i[number lowercase capital special_character].each do |c|
        Settings::Password.redefine_singleton_method(:"include_#{c}") { c.in?(included_characters) }
      end
      PasswordValidator.required_characters = included_characters.map { |c| I18n.t("password.#{c}") }.join(', ')
    end
  end
end
