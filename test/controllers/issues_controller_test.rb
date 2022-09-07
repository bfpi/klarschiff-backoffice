# frozen_string_literal: true

require 'test_helper'

class IssuesControllerTest < ActionDispatch::IntegrationTest
  %i[admin regional_admin editor].each do |role|
    test "authorized index for #{role}" do
      login username: role
      get '/issues'
      assert_response :success
    end
  end

  test 'accept responsibility' do
    login username: :admin
    issue = issue(:received_not_accepted)
    assert_not issue.responsibility_accepted
    assert_difference -> { LogEntry.where(issue_id: issue.id, attr: :responsibility_accepted, new_value: :Ja).count }, 1 do
      patch "/issues/#{issue.id}.js", params: { issue: { responsibility_action: :accept } }
      assert_response :success
      assert_predicate issue.reload, :responsibility_accepted
    end
  end

  test 'reject responsibility' do
    login username: :admin
    issue = issue(:received)
    assert_predicate issue, :responsibility_accepted
    patch "/issues/#{issue.id}.js", params: { issue: { responsibility_action: :reject } }
    assert_response :success
    assert_not issue.reload.responsibility_accepted
    entry = LogEntry.find_by(issue_id: issue.id, attr: 'responsibility_accepted', new_value: 'Nein')
    assert_predicate entry, :present?
    assert_in_delta Time.current, entry.created_at, 60
  end

  test 'close_as_not_solvable' do
    login username: :admin
    issue = issue(:received)
    assert_predicate issue, :status_received?
    patch "/issues/#{issue.id}.js", params: { issue: { responsibility_action: :close_as_not_solvable } }
    assert_response :success
    assert_not issue.reload.responsibility_accepted
    assert_predicate issue, :status_not_solvable?
    entry = LogEntry.find_by(
      issue_id: issue.id, attr: 'status', new_value: Issue.human_enum_name(:status, :not_solvable)
    )
    assert_predicate entry, :present?
    assert_in_delta Time.current, entry.created_at, 60
  end

  test 'manual responsibility change' do
    login username: :admin
    issue = issue(:received)
    assert_equal group(:internal), issue.group
    assert_predicate issue, :responsibility_accepted
    group = group(:internal2)
    patch "/issues/#{issue.id}.js", params: { issue: { group_id: group.id, responsibility_action: :manual } }
    assert_response :success
    assert_equal group, issue.reload.group
    assert_not issue.responsibility_accepted
    assert_equal group, issue.group
    entry = LogEntry.find_by(issue_id: issue.id, attr: 'group', new_value_id: group.id)
    assert_predicate entry, :present?
    assert_in_delta Time.current, entry.created_at, 60
  end

  test 'recalculate responsibility' do
    login username: :admin
    issue = issue(:received_not_accepted_two)
    assert_equal group(:internal2), issue.group
    patch "/issues/#{issue.id}.js", params: { issue: { responsibility_action: :recalculate } }
    assert_response :success
    group = group(:one)
    assert_equal group, issue.reload.group
    entry = LogEntry.find_by(issue_id: issue.id, attr: 'group', new_value_id: group.id)
    assert_predicate entry, :present?
    assert_in_delta Time.current, entry.created_at, 60
  end

  test 'unknown responsibility_action' do
    login username: :admin
    issue = issue(:received)
    patch "/issues/#{issue.id}.js", params: { issue: { responsibility_action: :test } }
    assert_response :success
    assert_empty LogEntry.where(issue_id: issue.id)
  end
end
