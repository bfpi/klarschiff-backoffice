# frozen_string_literal: true

unless Rails.env.development? || Rails.env.test?
  Rails.application.config.middleware.use ExceptionNotification::Rack,
    email: {
      email_prefix: '[KS-Backoffice] ',
      sender_address: ["\"Klarschiff-Backoffice (#{ENV['ENVIRONMENT']})\" <support-klarschiff@bfpi.de>"],
      exception_recipients: %w[support-klarschiff@bfpi.de]
    }
end
