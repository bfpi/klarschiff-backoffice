# frozen_string_literal: true

class Dms
  Result = Data.define(:status, :url)

  mattr_reader :config, default: Config.for(:dms)

  def self.login(username, password)
    config.keys.index_with { |target| api_for(target)&.login(username, password) }.compact
  end

  def self.logout(session_ids)
    session_ids.to_h.each { |target, session_id| api_for(target)&.logout(session_id) if session_id.present? }
  end

  def self.api_for(target)
    target_config = config[target]
    DmsApi.new(target_config) if target_config.is_a?(Hash) && target_config[:api].present?
  end
  private_class_method :api_for

  def initialize(issue, session_ids: nil)
    @issue = issue
    @target, @category = issue.dms.to_s.split(':', 2)
    @target_config = config[@target] if @target.present?
    @session_id = session_ids.to_h[@target] if @target.present?
  end

  def enabled?
    @target_config.is_a?(Hash) && @target_config[:api].present? && @category.present?
  end

  def lookup
    return unavailable unless enabled? && @session_id.present?
    document_id = search_document_id
    document_id ? Result.new(:found, api.document_url(document_id)) : Result.new(:not_found, create_link)
  rescue StandardError => e
    unavailable(e)
  end

  private

  def api
    @api ||= DmsApi.new(@target_config)
  end

  def search_document_id
    api.search(category: @category, property: search_property, value: @issue.id, session_id: @session_id)
  end

  def search_property
    @target_config.fetch(:search_property).fetch(@category)
  end

  def create_link
    template = @target_config.dig(:create_link, @category)
    return if template.blank?
    params = create_link_params.transform_values { |value| ERB::Util.url_encode(value.to_s) }
    I18n.interpolate(template, params)
  end

  def create_link_params
    {
      ks_id: @issue.id,
      ks_user: Current.user&.login,
      ks_str: "#{address['strasse_name']} (#{address['strasse_schluessel']} - #{address['gemeindeteil_name']})",
      ks_hnr: address['hausnummer'],
      ks_hnr_z: address['hausnummer_zusatz'],
      ks_eigentuemer: @issue.property_owner.to_s.truncate(254, omission: '…')
    }
  end

  def address
    @address ||= Geocodr.address_dms(@issue).then { |result| result.is_a?(Hash) ? result : {} }
  end

  def unavailable(error = nil)
    Rails.logger.error "d.3-Abfrage zu Meldung #{@issue.id} fehlgeschlagen: #{error.inspect}" if error
    Result.new(:unavailable, nil)
  end
end
