# frozen_string_literal: true

class Dms
  @dms ||= Config.for(:dms)

  def self.[](key)
    @dms[key.to_s].try(:with_indifferent_access)
  end

  def self.keys
    @dms.keys.map(&:to_s)
  end

  def self.exists?(config, ddc, issue_id, autoclose: true)
    result = Dms.request(config, config[:check_existence], ddc, issue_id)
    Dms.request(config, config[:reset_search], ddc, issue_id) if autoclose

    result.code.to_i == 200
  end

  def self.document_id(config, ddc, issue_id)
    Dms.exists?(config, ddc, issue_id, autoclose: false)
    result = Dms.request(config, config[:show], ddc, issue_id)
    doc = Nokogiri::XML(result.body)
    Dms.request(config, config[:reset_search], ddc, issue_id)
    return nil if result.code.to_i != 200
    doc.root.text
  end

  def self.create_link(config, ddc, issue)
    address = Geocodr.address_dms(issue)
    I18n.interpolate(config[:create][ddc],
      ks_id: issue.id,
      ks_user: Current.user.login,
      ks_str: "#{address['strasse_name']} (#{address['strasse_schluessel']} - #{address['gemeindeteil_name']})",
      ks_hnr: address['hausnummer'],
      ks_hnr_z: address['hausnummer_zusatz'],
      ks_eigentuemer: issue.property_owner)
  end

  def self.request(config, request, ddc, issue_id)
    uri = URI.parse([config[:api], I18n.interpolate(request, ddc: ddc, issue_id: issue_id)].join)
    req = Net::HTTP::Get.new(uri)

    request_http(config).start(uri.hostname, uri.port) do |http|
      return http.request(req)
    end

    nil
  end

  def self.request_http(config)
    if config[:proxy_host].present? && config[:proxy_port].present?
      Net::HTTP::Proxy(config[:proxy_host], config[:proxy_port])
    else
      Net::HTTP
    end
  end
end
