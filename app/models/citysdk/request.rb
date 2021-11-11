# frozen_string_literal: true

module Citysdk
  class Request < ::Issue
    include Citysdk::Serialization
    include Citysdk::RequestSetter
    include Citysdk::Request::Media

    attr_writer :lat, :long, :address_string

    self.serialization_attributes = %i[service_request_id]
    alias_attribute :service_request_id, :id
    alias_attribute :status_notes, :status_note
    alias_attribute :requested_datetime, :created_at
    alias_attribute :updated_datetime, :updated_at
    alias_attribute :description_public, :description_status_external?
    alias_attribute :photo_required, :photo_requested
    alias_attribute :detailed_status_datetime, :status_date
    alias_attribute :email, :author
    alias_attribute :service_code, :category_id

    def self.authorized(tips:)
      return all if tips
      includes(category: :main_category).where.not main_category: { kind: :tip }
    end

    def assign_attributes(attributes)
      super(attributes)
      set_position_from_attributes
    end

    def set_position_from_attributes
      return if @address_string.blank? && @lat.blank? && @long.blank?
      if ::Geocodr.valid?(@address_string)
        @long, @lat = ::Geocodr.find(@address_string).first['geometry']['coordinates']
      end
      self.position = "POINT(#{@long} #{@lat})"
    end

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

    def status_date; end

    def description
      return 'redaktionelle Prüfung ausstehend' if description_status_internal?
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

    private

    def extended_attributes
      ea = { detailed_status: detailed_status, detailed_status_datetime: detailed_status_datetime,
             description_public: description_public, expected_closure: expected_closure,
             priority: priority_before_type_cast, media_urls: media_urls, photo_required: photo_required,
             trust: trust_level_before_type_cast, votes: votes }
      ea[:property_owner] = property_owner if @property_attributes
      if @job_detail_attributes
        ea.merge! delegation: delegation_name, job_status: job_status, job_priority: job_priority
      end
      ea
    end

    def serializable_methods(options)
      @property_attributes = options[:property_details]
      @job_detail_attributes = options[:job_details]

      ret = []
      ret << :extended_attributes if options[:extensions]
      unless options[:show_only_id]
        ret |= %i[status_notes status service_code service_name description agency_responsible service_notice
                  requested_datetime updated_datetime expected_datetime address adress_id lat long media_url zipcode]
      end
      ret
    end
  end
end
