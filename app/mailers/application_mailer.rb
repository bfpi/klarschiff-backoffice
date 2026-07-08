# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  mattr_reader :mailer_config, default: Config.for(:mailer)

  default from: mailer_config[:default][:from]

  prepend_view_path 'overlay/views'
end
