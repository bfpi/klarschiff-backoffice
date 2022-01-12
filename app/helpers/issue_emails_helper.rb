# frozen_string_literal: true

module IssueEmailsHelper
  def truncate_text(text)
    return text unless request
    user_agent = UserAgent.new(request.user_agent)
    return text if user_agent.engine != :webkit
    truncate text, length: 1000
  end
end
