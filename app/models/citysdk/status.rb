# frozen_string_literal: true

module Citysdk
  class Status
    CITYSDK = { 'PENDING' => defined?(STATUS_CITYSDK_PENDING) ? STATUS_CITYSDK_PENDING : 'pending',
                'RECEIVED' => defined?(STATUS_CITYSDK_RECEIVED) ? STATUS_CITYSDK_RECEIVED : %w[received reviewed],
                'IN_PROCESS' => defined?(STATUS_CITYSDK_IN_PROCESS) ? STATUS_CITYSDK_IN_PROCESS : 'in_process',
                'PROCESSED' => defined?(STATUS_CITYSDK_PROCESSED) ? STATUS_CITYSDK_PROCESSED : 'closed',
                'REJECTED' => if defined?(STATUS_CITYSDK_REJECTED)
                                STATUS_CITYSDK_REJECTED
                              else
                                %w[duplicate not_solvable]
                              end }.freeze

    CITYSDK_WRITE = {
      'IN_PROCESS' => defined?(STATUS_CITYSDK_IN_PROCESS) ? STATUS_CITYSDK_IN_PROCESS : 'in_process',
      'PROCESSED' => defined?(STATUS_CITYSDK_PROCESSED) ? STATUS_CITYSDK_PROCESSED : 'closed',
      'REJECTED' => defined?(STATUS_CITYSDK_REJECTED) ? STATUS_CITYSDK_REJECTED : 'not_solvable'
    }.freeze

    PERMISSABLE_CITYSDK_KEYS = %w[IN_PROCESS PROCESSED REJECTED].freeze

    OPEN311 = { 'open' => (if defined?(STATUS_OPEN311_OPEN)
                             STATUS_OPEN311_OPEN
                           else
                             %w[pending received reviewed in_process]
                           end),
                'closed' => (if defined?(STATUS_OPEN311_CLOSED)
                               STATUS_OPEN311_CLOSED
                             else
                               %w[closed duplicate
                                  not_solvable]
                             end) }.freeze

    NON_PUBLIC = 'intern'

    DELETED = I18n.t('citydsk.status.deleted')

    def initialize(status)
      @citysdk = CITYSDK.find { |_k, v| v.include?(status) }.try(:first)
      @open311 = OPEN311.find { |k, v| k.eql?(status) || v.include?(status) }.first
      @backend = status
    end

    def self.open311_for_backoffice(open311_status)
      OPEN311.slice(*Array(open311_status).map(&:downcase)).values.flatten.map { |s| Issue.statuses[s] }
    end

    def self.citysdk_for_backoffice(citysdk_status)
      CITYSDK.slice(*Array(citysdk_status).map(&:upcase)).values.flatten.map { |s| Issue.statuses[s] }
    end

    def self.valid_filter_values(values, target = :open311)
      values = values.split(/, ?/) if values.is_a?(String)
      (matches = case target
                 when :open311
                   OPEN311.keys
                 when :citysdk
                   CITYSDK.keys
                 else
                   raise 'Unknown status target'
                 end.map(&:upcase) & values.map(&:upcase)) && matches.size == values.size
    end

    def to_citysdk
      @citysdk
    end

    def to_open311
      @open311
    end

    def to_backend
      @backend
    end
  end
end
