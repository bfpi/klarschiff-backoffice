# frozen_string_literal: true

module Citysdk
  module RequestSetter
    extend ActiveSupport::Concern

    def detailed_status=(value)
      unless value.in?(Citysdk::Status::PERMISSABLE_CITYSDK_KEYS | [detailed_status])
        errors.add :status, :invalid
        raise ActiveRecord::RecordInvalid, self
      end
      return if (new_status = Citysdk::Status::CITYSDK[value]).blank?
      self.status = new_status
    end

    def priority=(value)
      unless Issue.priorities.value?(value.to_i)
        errors.add :priority, :invalid
        raise ActiveRecord::RecordInvalid, self
      end
      super(value.to_i)
    end

    def privacy_policy_accepted=(value); end

    def delegation=(value)
      if (new_delegation = Group.kind_external.find_by(short_name: value)).blank?
        errors.add :delegation, :invalid
        raise ActiveRecord::RecordInvalid, self
      end
      super(new_delegation)
    end

    def job_status=(value)
      return unless job
      unless value.in?(Job.citysdk_statuses.values)
        errors.add :job_status, :invalid
        raise ActiveRecord::RecordInvalid, self
      end
      job.status = Job.citysdk_statuses.find { |k, v| k if v == value }.first
      job.save
    end

    def job_priority=(value)
      return unless job
      job.order = value.to_i
      job.save
    end
  end
end