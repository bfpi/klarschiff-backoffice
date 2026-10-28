# frozen_string_literal: true

class DmsController < ApplicationController
  def index
    issue = Issue.find(params.expect(:issue_id))
    check_auth(:show_issue, issue)
    @result = Dms.new(issue, session_ids: session[:dms_session_id]).lookup
    render layout: false
  end
end
