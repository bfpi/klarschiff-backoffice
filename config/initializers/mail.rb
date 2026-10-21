# frozen_string_literal: true

return if Rails.env.in?(%w[production test]) && !ENV.fetch('INTERCEPT_ALL_MAILS', false)

require Rails.root.join('lib/consolidation_email_interceptor')

ActionMailer::Base.register_interceptor ConsolidationEmailInterceptor
