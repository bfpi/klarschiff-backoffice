# frozen_string_literal: true

class DmsApi
  class Error < StandardError; end

  SESSION_COOKIE = 'AuthSessionId'
  SESSION_COOKIE_PATTERN = /\A\s*#{SESSION_COOKIE}=([^;]+)/
  USER_AGENT = 'Klarschiff-Backoffice'

  def initialize(config)
    @config = config
  end

  def login(username, password)
    response = get('/identityprovider/login/') { |request| request.basic_auth(username, password) }
    session_id = session_id_from(response) if response.is_a?(Net::HTTPOK)
    return session_id if session_id.present?
    Rails.logger.error "d.3-Login für #{username}: kein Session-Token erhalten (HTTP #{response.code})"
    nil
  rescue StandardError => e
    Rails.logger.error "d.3-Login für #{username} fehlgeschlagen: #{e.inspect}"
    nil
  end

  def logout(session_id)
    response = get('/identityprovider/logout', session_id:)
    return if response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPRedirection)
    Rails.logger.error "d.3-Logout fehlgeschlagen (HTTP #{response.code})"
  rescue StandardError => e
    Rails.logger.error "d.3-Logout fehlgeschlagen: #{e.inspect}"
  end

  def search(category:, property:, value:, session_id:)
    response = get("/dms/r/#{repository}/srm", search_params(category, property, value), session_id:)
    raise Error, "d.3-Suche lieferte HTTP #{response.code}" unless response.is_a?(Net::HTTPOK)
    JSON.parse(response.body).dig('items', 0, 'id').presence
  end

  def document_url(document_id)
    "#{base_url}/dms/r/#{repository}/o2/#{ERB::Util.url_encode(document_id.to_s)}"
  end

  private

  def base_url
    @config[:api].to_s.chomp('/')
  end

  def repository
    @config[:repository]
  end

  def timeout
    @config.fetch(:timeout)
  end

  def search_params(category, property, value)
    {
      sourceId: "/dms/r/#{repository}/source",
      sourceCategories: [category].to_json,
      sourceProperties: { property => [value.to_s] }.to_json
    }
  end

  def get(path, params = nil, session_id: nil)
    uri = URI.parse("#{base_url}#{path}")
    uri.query = URI.encode_www_form(params) if params
    request = Net::HTTP::Get.new(uri, 'Accept' => 'application/json', 'User-Agent' => USER_AGENT)
    request['Cookie'] = "#{SESSION_COOKIE}=#{session_id}" if session_id
    yield request if block_given?
    connection(uri).request(request)
  end

  def connection(uri)
    Net::HTTP.new(uri.host, uri.port, *proxy).tap do |http|
      http.use_ssl = uri.scheme == 'https'
      http.open_timeout = timeout
      http.read_timeout = timeout
      http.write_timeout = timeout
      http.max_retries = 0
    end
  end

  def proxy
    return [:ENV] if @config[:proxy_host].blank?
    [@config[:proxy_host], @config[:proxy_port]]
  end

  def session_id_from(response)
    Array(response.get_fields('set-cookie')).filter_map { |cookie| cookie[SESSION_COOKIE_PATTERN, 1] }.first
  end
end
