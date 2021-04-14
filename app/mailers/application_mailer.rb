# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  mattr_reader :mailer_config, default: Rails.application.config_for(:mailer).with_indifferent_access

  default from: mailer_config[:default][:from]

  prepend_view_path 'overlay/views'

  def mail(options = {})
    options.with_defaults!(mailer_config.dig(mailer_name, caller_locations(1..1).first.label.to_sym) || {})
    (options.delete(:interpolation) || {}).each do |target, values|
      options[target] = I18n.interpolate(options[target], values)
    end
    super options
  end
end
