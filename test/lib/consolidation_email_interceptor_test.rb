# frozen_string_literal: true

require 'test_helper'
require 'mail'

class ConsolidationEmailInterceptorTest < ActiveSupport::TestCase
  %w[development consolidation].each do |env|
    test "enabled in #{env}" do
      with_env(env) { assert_predicate ConsolidationEmailInterceptor, :enabled? }
    end
  end

  %w[production test].each do |env|
    test "disabled in #{env} without INTERCEPT_ALL_MAILS" do
      with_env(env) { assert_not_predicate ConsolidationEmailInterceptor, :enabled? }
    end

    %w[1 true].each do |value|
      test "enabled in #{env} with INTERCEPT_ALL_MAILS=#{value}" do
        with_env(env, intercept_all_mails: value) { assert_predicate ConsolidationEmailInterceptor, :enabled? }
      end
    end

    ['', '0', 'false'].each do |value|
      test "disabled in #{env} with INTERCEPT_ALL_MAILS=#{value.inspect}" do
        with_env(env, intercept_all_mails: value) { assert_not_predicate ConsolidationEmailInterceptor, :enabled? }
      end
    end
  end

  %i[smtp sendmail].each do |delivery_method|
    test "redirect mail with delivery method #{delivery_method}" do
      message = build_message(delivery_method:)
      ConsolidationEmailInterceptor.delivering_email(message)

      assert_equal [Config.for(:mailer).dig(:default, :interceptions_recipient)], message.to
      assert_nil message.cc
      assert_nil message.bcc
      assert_equal 'Betreff (To: to@example.com, CC: cc@example.com, BCC: bcc@example.com)', message.subject
    end
  end

  test 'do not redirect mail with delivery method test' do
    assert_unchanged build_message(delivery_method: :test)
  end

  test 'do not redirect mail with X-Override-Consolidation header' do
    assert_unchanged build_message(delivery_method: :smtp, override_consolidation: true)
  end

  private

  def with_env(rails_env, intercept_all_mails: nil, &block)
    original = ENV.fetch('INTERCEPT_ALL_MAILS', nil)
    ENV['INTERCEPT_ALL_MAILS'] = intercept_all_mails
    Rails.stub(:env, ActiveSupport::EnvironmentInquirer.new(rails_env)) { yield if block }
  ensure
    ENV['INTERCEPT_ALL_MAILS'] = original
  end

  def build_message(delivery_method:, override_consolidation: false)
    Mail.new(to: 'to@example.com', cc: 'cc@example.com', bcc: 'bcc@example.com', subject: 'Betreff').tap do |message|
      message.delivery_method delivery_method
      message.header['X-Override-Consolidation'] = true if override_consolidation
    end
  end

  def assert_unchanged(message)
    ConsolidationEmailInterceptor.delivering_email(message)

    assert_equal ['to@example.com'], message.to
    assert_equal ['cc@example.com'], message.cc
    assert_equal ['bcc@example.com'], message.bcc
    assert_equal 'Betreff', message.subject
  end
end
