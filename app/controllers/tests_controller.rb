# frozen_string_literal: true

class TestsController < ApplicationController
  include Filter
  before_action { check_auth :test }

  PERMITTED_JOBS = %w[
    ArchiveClosedIssuesJob
    CalculateAverageTurnaroundTimeJob
    DeleteAuthorsAfterDeadlineJob
    DeleteUnconfirmedAbuseReportsJob
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
    test = params[:test].to_sym
    return send(test) if PERMITTED_TESTS.include?(test) && respond_to?(test, true)
    render plain: 'Test unbekannt', status: :bad_request
  end

  private

  def run_job
    job = params[:job]
    return render plain: 'Job unbekannt', status: :bad_request unless PERMITTED_JOBS.include?(job)
    job.constantize.perform_now
    render plain: "#{job} erfolgreich ausgeführt", status: :ok
  rescue StandardError => e
    render plain: e.message, status: :bad_request
  end

  def protocol_email
    return render plain: 'Kein Empfänger angegeben', status: :bad_request if params[:recipient].blank?
    TestMailer.test(to: params[:recipient]).deliver_now
    render plain: "Testnachricht an #{params[:recipient]} versandt.", status: :ok
  end

  def protocol_ldap
    begin
      protocol_ldap_search(protocol_ldap_bind)
    rescue Net::LDAP::NoBindResultError
      return render plain: 'LDAP-Verbindung nicht möglich. Eventuell falsche Encryption Einstellung.',
        status: :bad_request
    rescue StandardError => e
      return render plain: e.message, status: :bad_request
    end
    render plain: 'LDAP-Verbindung erfolgreich', status: :ok
  end

  def protocol_ldap_bind
    conn = Net::LDAP.new(host: params[:host], port: params[:port], encryption: params[:encryption])
    conn.auth params[:username], params[:password]
    conn.bind
    conn
  rescue Net::LDAP::NoBindResultError
    raise 'LDAP-Verbindung nicht möglich. Eventuell falsche Encryption Einstellung.'
  end

  def protocol_ldap_search(conn)
    if (ldap_error = conn.as_json['result']['ldap_result']['errorMessage']).present?
      raise "LDAP-Result: #{ldap_error}"
    end
    raise 'LDAP-User/Login ungültig' if conn.search(base: params[:username]).as_json.blank?
  end
end
