# frozen_string_literal: true

class Dms
  mattr_reader :config, default: Config.for(:dms)

  def initialize(issue)
    @issue = issue
    target, @ddc = @issue.dms.try(:split, ':')
    return if target.blank?
    @dms = config[target]
  end

  def exists?
    return false if @dms.blank?
    res = request(:start_search)
    request :close_search
    Nokogiri::XML(res.body).root.text.to_i == 1
  end

  def document_id
    return if @dms.blank?
    request :start_search
    res = request(:get_doc)
    return unless res.code.to_i == 200
    request :close_search
    Nokogiri::XML(res.body).root.text
  end

  def link
    return if @dms.blank?
    address = Geocodr.address_dms(@issue)
    @dms[:create_link][@ddc].gsub('{ks_id}', @issue.id.to_s).gsub('{ks_user}', Current.user.login)
      .gsub('{ks_str}',
        "#{address['strasse_name']} (#{address['strasse_schluessel']} - #{address['gemeindeteil_name']})")
      .gsub('{ks_hnr}', address['hausnummer'])
      .gsub('{ks_hnr_z}', address['hausnummer_zusatz'].presence || '')
      .gsub('{ks_eigentuemer}',
        @issue.property_owner.present? ? @issue.property_owner.truncate(254, omission: '…') : '')
  end

  private

  def request(key)
    uri = URI.parse([@dms[:api], I18n.interpolate(@dms[key], ddc: @ddc, issue_id: @issue.id)].join)
    if (host = @dms[:proxy_host]).present? && (port = @dms[:proxy_port]).present?
      Net::HTTP::Proxy host, port
    else
      Net::HTTP
    end.get_response uri
  end
end
