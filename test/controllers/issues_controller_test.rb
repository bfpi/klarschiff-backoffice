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

  sort_dirs = %i[asc desc]
  %i[id created_at category status address supporter group updated_at last_editor priority].each do |column|
    sort_dirs.each do |dir|
      test "should sort by #{column} #{dir} as auth_code user" do
        get "/issues?auth_code=#{auth_code(:one).uuid}"
        assert_response :success
        get "/issues?order_by[column]=#{column}&order_by[dir]=#{dir}"
        assert_response :success
      end

      TEST_ROLES.each do |role|
        test "should sort by #{column} #{dir} as #{role}" do
          login username: role
          get "/issues?order_by[column]=#{column}&order_by[dir]=#{dir}"
          assert_response :success
        end
      end
    end
  end

  test 'accept responsibility' do
    login username: :admin
    issue = issue(:received_not_accepted)
    assert_not issue.responsibility_accepted
    expression = -> { LogEntry.where(issue_id: issue.id, attr: :responsibility_accepted, new_value: :Ja).count }
    assert_difference expression, 1 do
      patch "/issues/#{issue.id}.js", params: { issue: { responsibility_action: :accept } }
    end
    assert_response :success
    assert_predicate issue.reload, :responsibility_accepted
  end

  test 'reject responsibility' do
    login username: :admin
    issue = issue(:received)
    assert_predicate issue, :responsibility_accepted
    expression = -> { LogEntry.where(issue_id: issue.id, attr: :responsibility_accepted, new_value: :Nein).count }
    assert_difference expression, 1 do
      patch "/issues/#{issue.id}.js", params: { issue: { responsibility_action: :reject } }
    end
    assert_response :success
    assert_not issue.reload.responsibility_accepted
  end

  test 'close_as_not_solvable' do
    login username: :admin
    issue = issue(:received)
    assert_predicate issue, :status_received?
    expression = lambda {
      LogEntry.where(issue_id: issue.id, attr: :status, new_value: Issue.human_enum_name(:status, :not_solvable)).count
    }
    assert_difference expression, 1 do
      patch "/issues/#{issue.id}.js", params: { issue: { responsibility_action: :close_as_not_solvable } }
    end
    assert_response :success
    assert_not issue.reload.responsibility_accepted
    assert_predicate issue, :status_not_solvable?
  end

  test 'manual responsibility change' do
    login username: :admin
    issue = issue(:received)
    assert_equal group(:internal), issue.group
    assert_predicate issue, :responsibility_accepted
    group = group(:internal2)
    expression = -> { LogEntry.where(issue_id: issue.id, attr: 'group', new_value_id: group.id).count }
    assert_difference expression, 1 do
      patch "/issues/#{issue.id}.js", params: { issue: { group_id: group.id, responsibility_action: :manual } }
    end
    assert_response :success
    assert_equal group, issue.reload.group
    assert_not issue.responsibility_accepted
  end

  test 'no changes on manual responsibility change to same group' do
    login username: :admin
    issue = issue(:received_not_accepted_two)
    assert_no_difference 'LogEntry.count' do
      patch "/issues/#{issue.id}.js", params: { issue: { group_id: issue.group_id, responsibility_action: :manual } }
    end
    assert_response :success
    assert_equal issue.group_id, issue.reload.group_id
    assert_not issue.responsibility_accepted
  end

  test 'recalculate responsibility' do
    login username: :admin
    issue = issue(:received_not_accepted_two)
    assert_equal group(:internal2), issue.group
    expected_target_group_id = group(:one).id
    expression = -> { LogEntry.where(issue_id: issue.id, attr: 'group', new_value_id: expected_target_group_id).count }
    assert_difference expression, 1 do
      patch "/issues/#{issue.id}.js", params: { issue: { responsibility_action: :recalculate } }
    end
    assert_response :success
    assert_equal expected_target_group_id, issue.reload.group_id
  end

  test 'unknown responsibility_action' do
    login username: :admin
    issue = issue(:received)
    assert_no_difference -> { LogEntry.where(issue_id: issue.id).count } do
      patch "/issues/#{issue.id}.js", params: { issue: { responsibility_action: :test } }
    end
    assert_response :success
  end

  test 'set_status from responsibility mail without status_parameter' do
    with_gui_access_for_external_participants(value: false) do
      auth_code = auth_code(:reference_default)
      assert_no_changes 'issue(:reference_default).reload' do
        get "/issues/#{auth_code.uuid}/set_status"
        assert_response :unprocessable_entity
      end
    end
  end

  %i[in_process closed not_solvable duplicate].each do |status|
    test "set_status from responsibility mail to #{status}" do
      with_gui_access_for_external_participants(value: false) do
        auth_code = auth_code(:reference_default)
        get "/issues/#{auth_code.uuid}/set_status?status=#{status}"
        assert_response :success
        assert_equal status.to_s, issue(:reference_default).status
      end
    end
  end
end
