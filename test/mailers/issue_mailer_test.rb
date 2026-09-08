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

  %i[enabled disabled].each do |option|
    test "issue in_process with forward logging #{option}" do
      with_log_issue_mailer_forward_settings(log_issue_mailer_forward: option == :enabled) do
        issue = issue(:in_process)
        assert_emails 1 do
          assert_no_difference 'LogEntry.count' do
            mail = IssueMailer.in_process(to: issue.author, issue:)

            assert_equal "##{issue.id}: in Bearbeitung", mail.subject
            assert_equal ['test@rostock.de'], mail.to
            assert_equal ['from@example.com'], mail.from
            msg = "Ihre Meldung ##{issue.id} vom #{I18n.l(issue.created_at,
              format: :elaborate)}, ist nun in Bearbeitung."
            assert_match msg, mail.body.encoded
            mail.deliver_now
          end
        end
      end
    end

    test "issue closed with forward logging #{option}" do
      with_log_issue_mailer_forward_settings(log_issue_mailer_forward: option == :enabled) do
        issue = issue(:in_process)
        assert_emails 1 do
          assert_no_difference 'LogEntry.count' do
            mail = IssueMailer.closed(to: issue.author, issue:)

            assert_equal "##{issue.id}: abgeschlossen", mail.subject
            assert_equal ['test@rostock.de'], mail.to
            assert_equal ['from@example.com'], mail.from
            msg = "die Bearbeitung Ihrer Meldung ##{issue.id} vom #{I18n.l(issue.created_at,
              format: :elaborate)}, ist abgeschlossen"
            assert_match msg, mail.body.encoded
            mail.deliver_now
          end
        end
      end
    end

    test "issue delegation with forward logging #{option}" do
      with_log_issue_mailer_forward_settings(log_issue_mailer_forward: option == :enabled) do
        issue = issue(:in_process)
        assert_emails 1 do
          assert_no_difference 'LogEntry.count' do
            mail = IssueMailer.delegation(to: issue.group.email, issues: [issue],
              auth_codes: [AuthCode.find_by(issue_id: issue, group_id: issue.group)])

            assert_equal 'Neue delegierte Meldungen', mail.subject
            assert_equal ['internal@example.com'], mail.to
            assert_equal ['from@example.com'], mail.from
            msg = 'innerhalb der letzten 24 Stunden wurden Meldungen an Sie delegiert.'
            assert_match msg, mail.body.encoded
            mail.deliver_now
          end
        end
      end
    end

    test "issue inform_editorial_staff with forward logging #{option}" do
      with_log_issue_mailer_forward_settings(log_issue_mailer_forward: option == :enabled) do
        issue = issue(:in_process)
        assert_emails 1 do
          assert_no_difference 'LogEntry.count' do
            days = %i[open_but_not_accepted in_work_without_status_note
                      open_ideas_without_minimum_supporters created_not_in_work].map { |k| { k => 14 } }
            mail = IssueMailer.inform_editorial_staff(to: issue.group.email, issues: [issue], days:)

            assert_equal "#{Settings::Instance.name}: wichtige redaktionelle Hinweise", mail.subject
            assert_equal ['internal@example.com'], mail.to
            assert_equal ['from@example.com'], mail.from
            msg = 'bitte beachten Sie diese wichtigen redaktionellen Hinweise:'
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
