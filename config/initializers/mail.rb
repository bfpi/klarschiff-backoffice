# frozen_string_literal: true

require Rails.root.join('lib/consolidation_email_interceptor')

ActionMailer::Base.register_interceptor ConsolidationEmailInterceptor if ConsolidationEmailInterceptor.enabled?
