# frozen_string_literal: true

class TestsController < ApplicationController
  include Filter
  before_action { check_auth :test }

  PERMITTED_JOBS = %w[
    ArchiveClosedIssuesJob
    CalculateAverageTurnaroundTimeJob
    DeleteAuthorsAfterDeadlineJob
    DeleteUnconfirmedAbuseReportsJob
    DeleteUnconfirmedCompletionsJob
    DeleteUnconfirmedIssuesJob
    DeleteUnconfirmedPhotosJob
    DeleteUnconfirmedSupportersJob
    InformEditorialStaffOnIssuesJob
    InformOnDelegatedIssuesJob
    NotifyOnClosedIssuesJob
    NotifyOnIssuesInProcessJob
  ].freeze
  PERMITTED_TESTS = %i[protocol_email protocol_ldap run_job].freeze

  def index; end

  def create
    test = PERMITTED_TESTS.find { |t| t == params[:test].to_sym }
    return render plain: t('activerecord.tests.test_unknown'), status: :bad_request unless test
    send test
  end

  private

  def run_job
    job = PERMITTED_JOBS.find { |j| j == params[:job] }
    return render plain: t('activerecord.tests.job_unknown'), status: :bad_request unless job
    job.constantize.perform_now
    render plain: t('activerecord.tests.job_executed', job:), status: :ok
  rescue StandardError => e
    render plain: e.message, status: :bad_request
  end

  def protocol_email
    return render plain: t('activerecord.tests.no_recipient'), status: :bad_request if params[:recipient].blank?
    TestMailer.test(to: params[:recipient]).deliver_now
    render plain: t('activerecord.tests.test_mail_send', recipient: params[:recipient]), status: :ok
  end

  def protocol_ldap
    begin
      protocol_ldap_search(protocol_ldap_bind)
    rescue Net::LDAP::NoBindResultError
      return render plain: t('activerecord.tests.no_ldap_connection'),
        status: :bad_request
    rescue StandardError => e
      return render plain: e.message, status: :bad_request
    end
    render plain: t('activerecord.tests.ldap_success'), status: :ok
  end

  def protocol_ldap_bind
    conn = Net::LDAP.new(host: params[:host], port: params[:port], encryption: params[:encryption])
    conn.auth params[:username], params[:password]
    conn.bind
    conn
  rescue Net::LDAP::NoBindResultError
    raise t('activerecord.tests.no_ldap_connection')
  end

  def protocol_ldap_search(conn)
    if (ldap_error = conn.as_json['result']['ldap_result']['errorMessage']).present?
      raise "LDAP-Result: #{ldap_error}"
    end
    raise t('activerecord.tests.ldap_login_error') if conn.search(base: params[:username]).as_json.blank?
  end
end
