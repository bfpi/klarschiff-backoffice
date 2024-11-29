# frozen_string_literal: true

unless Rails.env.local?
  require Rails.root.join('app/modules/config.rb').to_s

  config = Config.for(:mailer)
  Rails.application.config.middleware.use ExceptionNotification::Rack,
    email: {
      email_prefix: '[KS-Backoffice Exception] ',
      sender_address: ["\"Klarschiff-Backoffice (#{Rails.env})\" <#{config[:default][:from]}>"],
      exception_recipients: config[:default][:exceptions_recipient],
      email_headers: { 'X-Override-Consolidation': true }
    }
end
