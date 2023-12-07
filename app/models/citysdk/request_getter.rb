# frozen_string_literal: true

module Citysdk
  module RequestGetter
    extend ActiveSupport::Concern

    def agency_responsible
      group.name.dup.tap { |v| v << " [delegiert an: #{delegation.name}]" if delegation }
    end

    def service_code
      category.id
    end

    def service_name
      category.sub_category.to_s
    end

    def service_notice; end

    def expected_datetime
      job&.date
    end

    def adress_id; end

    def lat
      position.y
    end

    def long
      position.x
    end

    def zipcode; end

    def detailed_status
      Citysdk::Status.new(status).to_citysdk
    end

    def description_public
      description_status_external?
    end

    def detailed_status_datetime
      status_date
    end

    def updated_datetime
      updated_at
    end

    def requested_datetime
      created_at
    end

    def status_date; end

    def description
      return default_group_message if default_group_without_gui_access?
      return I18n.t('request.description.internal') if description_status_internal?
      super
    end

    def votes
      supporters.size # use eager loaded relation for count instead of AR count
    end

    def job_status
      return nil unless job
      Job.citysdk_statuses[job.status.to_sym]
    end

    def job_priority
      return nil unless job
      job.order
    end

    def delegation_name
      return nil unless delegation
      delegation.short_name
    end

    def create_message
      message = [I18n.t('request.create_message.success')]
      message << default_group_message if default_group_without_gui_access?
      message.join
    end
  end
end
