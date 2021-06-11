# frozen_string_literal: true

unless Rails.env.development? || Rails.env.test?
  config = Config.for(:mailer)
  Rails.application.config.middleware.use ExceptionNotification::Rack,
    email: {
      email_prefix: '[KS-Backoffice Exception] ',
      sender_address: ["\"Klarschiff-Backoffice (#{Rails.env.to_s})\" <#{config[:default][:from]}>"],
      exception_recipients: config[:default][:exceptions_recipient],
      email_headers: { 'X-Override-Consolidation': true }
    }
end
