# frozen_string_literal: true

unless Rails.env.development? || Rails.env.test?
  config = Config.for(:mailer)
  Rails.application.config.middleware.use ExceptionNotification::Rack,
    email: {
      email_prefix: '[KS-Backoffice] ',
      sender_address: ["\"Klarschiff-Backoffice (#{ENV['ENVIRONMENT']})\" <#{config[:default][:from]}>"],
      exception_recipients: config[:default][:exceptions_recipient],
      email_headers: { 'X-Override-Consolidation': true }
    }
end
