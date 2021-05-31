# frozen_string_literal: true

module IssueMailerHelper
  def status_with_optional_status_note(issue)
    v = [issue.human_enum_name(:status)]
    v << "(#{Issue.human_attribute_name :status_note}: #{issue.status_note})" if issue.status_note.present?
    v.join ' '
  end
end
