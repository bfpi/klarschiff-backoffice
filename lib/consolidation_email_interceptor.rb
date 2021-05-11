# frozen_string_literal: true

class ConsolidationEmailInterceptor
  class << self
    def delivering_email(message)
      delivery_method = message.delivery_method
      return unless delivery_method.is_a? Mail::SMTP
      return if /true/i.match?(message.header['X-Override-Consolidation'].to_s)
      message.subject = "#{message.subject} (#{original_recipients message})"
      message.to = Config.for(:mailer).dig(:default, :interceptions_recipient)
      message.cc = nil
      message.bcc = nil
    end

    private

    def original_recipients(message)
      { To: message.header['To'], CC: message.header['Cc'], BCC: message.header['Bcc'] }
        .select { |_, v| v.present? }.map { |k, v| "#{k}: #{v}" }.join ', '
    end
  end
end
