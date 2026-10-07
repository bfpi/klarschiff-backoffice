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
    return unless address

    street = format_street(address)
    housenumber, housenumber_addition = format_housenumber(address)

    interpolate_link(street, housenumber, housenumber_addition)
  end

  private

  def format_street(address)
    "#{address.street_name} (#{address.street_key} - #{address.place_name})"
  end

  def format_housenumber(address)
    match = address.housenumber.match(/\A(\d+)([A-Za-z]*)\z/)
    match ? match.captures : ['', '']
  end

  def interpolate_link(street, housenumber, housenumber_addition)
    I18n.interpolate @dms[:create_link][@ddc],
      ks_id: @issue.id,
      ks_user: Current.user.login,
      ks_str: street,
      ks_hnr: housenumber,
      ks_hnr_z: housenumber_addition,
      ks_eigentuemer: @issue.property_owner.truncate(254, omission: '…')
  end

  def request(key)
    uri = URI.parse([@dms[:api], I18n.interpolate(@dms[key], ddc: @ddc, issue_id: @issue.id)].join)
    if (host = @dms[:proxy_host]).present? && (port = @dms[:proxy_port]).present?
      Net::HTTP::Proxy host, port
    else
      Net::HTTP
    end.get_response uri
  end
end
