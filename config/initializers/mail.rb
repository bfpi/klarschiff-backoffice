# frozen_string_literal: true

require Rails.root.join('lib/consolidation_email_interceptor')

ActionMailer::Base.register_interceptor ConsolidationEmailInterceptor unless Rails.env.in?(%w[production test])
