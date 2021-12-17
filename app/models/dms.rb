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
    res.code.to_i == 200 && Nokogiri::XML(res.body).root.text.to_i == 1
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
    I18n.interpolate @dms[:create_link][@ddc],
      ks_id: @issue.id,
      ks_user: Current.user.login,
      ks_str: "#{address['strasse_name']} (#{address['strasse_schluessel']} - #{address['gemeindeteil_name']})",
      ks_hnr: address['hausnummer'],
      ks_hnr_z: address['hausnummer_zusatz'],
      ks_eigentuemer: @issue.property_owner.truncate(254, omission: '…')
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
