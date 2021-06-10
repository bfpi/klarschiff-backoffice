# frozen_string_literal: true

require 'test_helper'

class InformOnDelegatedIssuesJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup { ActionMailer::Base.deliveries.clear }

  test 'perform and mails get sent' do
    assert_emails 0
    assert_nothing_raised { InformOnDelegatedIssuesJob.perform_now }
    assert_emails 1
    mail = ActionMailer::Base.deliveries.first
    group(:external).users.pluck(:email).each { |email| assert_includes mail.to, email }
    assert_equal 'Neue delegierte Vorgänge', mail.subject
  end
end
