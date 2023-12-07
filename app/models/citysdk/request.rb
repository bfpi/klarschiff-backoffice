# frozen_string_literal: true

module Citysdk
  class Request < ::Issue
    include Citysdk::BecomesIfValid
    include Citysdk::PrivacyPolicy
    include Citysdk::Request::CallbackSkips
    include Citysdk::Request::Media
    include Citysdk::RequestGetter
    include Citysdk::RequestSetter
    include Citysdk::Serialization

    attr_writer :lat, :long, :address_string

    self.serialization_attributes = %i[service_request_id]
    alias_attribute :email, :author
    alias_attribute :photo_required, :photo_requested
    alias_attribute :service_code, :category_id
    alias_attribute :service_request_id, :id
    alias_attribute :status_notes, :status_note

    def self.authorized(tips:)
      return all if tips
      includes(category: :main_category).where.not main_category: { kind: :tip }
    end

    def assign_attributes(attributes)
      super(attributes)
      set_position_from_attributes
    end

    private

    def default_group_message
      key = "request.description.default_group_#{group.type.to_s.downcase}"
      return I18n.t(key) if I18n.exists?(key)
      I18n.t('request.description.default_group')
    end

    def extended_attributes
      ea = { detailed_status:, detailed_status_datetime:, description_public:, expected_closure:, votes:,
             priority: priority_before_type_cast, media_urls:, photo_required:, trust: trust_level_before_type_cast }
      ea[:property_owner] = property_owner if @property_attributes
      ea.merge!(delegation: delegation_name, job_status:, job_priority:) if @job_detail_attributes
      ea
    end

    def serializable_methods(options)
      @property_attributes = options[:property_details]
      @job_detail_attributes = options[:job_details]

      ret = []
      ret << :extended_attributes if options[:extensions]
      ret << :create_message if options[:status] == 201
      unless options[:show_only_id]
        ret |= %i[status_notes status service_code service_name description agency_responsible service_notice
                  requested_datetime updated_datetime expected_datetime address adress_id lat long media_url zipcode]
      end
      ret
    end
  end
end
