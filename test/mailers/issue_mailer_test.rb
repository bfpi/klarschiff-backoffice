# frozen_string_literal: true

require 'test_helper'

class IssueMailerTest < ActionMailer::TestCase
  test 'forward' do
    with_log_issue_mailer_forward_settings(log_issue_mailer_forward: false) do
      user = user(:editor)
      Current.set(user:) do
        issue = issue(:in_process)
        issue_email = IssueEmail.new(valid_params)
        issue_email.issue_id = issue.id
        issue_email.validate

        assert_emails 1 do
          assert_no_difference 'LogEntry.count' do
            mail = IssueMailer.forward(issue_email:)

            assert_equal 'Weitergeleitete Meldung aus dem Beteiligungsportal Klarschiff MV', mail.subject
            assert_equal ['test@example.com'], mail.to
            assert_equal ['from@example.com'], mail.from
            msg = "die folgende Meldung wurde durch die/den #{
              Settings::Instance.name}-Nutzer/-in #{user} an Sie weitergeleitet"
            assert_match msg, mail.body.encoded
            mail.deliver_now
          end
        end
      end
    end
  end

  test 'forward with logging enabled' do
    with_log_issue_mailer_forward_settings(log_issue_mailer_forward: true) do
      user = user(:editor)
      Current.set(user:) do
        issue = issue(:in_process)
        issue_email = IssueEmail.new(valid_params)
        issue_email.issue_id = issue.id
        issue_email.validate

        assert_emails 1 do
          assert_difference 'LogEntry.count', 1 do
            mail = IssueMailer.forward(issue_email:)

            assert_equal 'Weitergeleitete Meldung aus dem Beteiligungsportal Klarschiff MV', mail.subject
            assert_equal ['test@example.com'], mail.to
            assert_equal ['from@example.com'], mail.from
            msg = "die folgende Meldung wurde durch die/den #{
              Settings::Instance.name}-Nutzer/-in #{user} an Sie weitergeleitet"
            assert_match msg, mail.body.encoded
            mail.deliver_now
          end
        end
      end
    end
  end

  private

  def valid_params
    {
      from: 'Absender Name', from_email: 'test@example.com', to_email: 'test@example.com', text: 'Lorem ipsum dolor',
      send_map: 1, send_photos: 1, send_comments: 1, send_feedbacks: 1, send_abuse_reports: 1
    }
  end
end
