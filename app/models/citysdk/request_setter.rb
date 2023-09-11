# frozen_string_literal: true

module Citysdk
  module RequestSetter
    extend ActiveSupport::Concern

    def set_position_from_attributes
      return if @address_string.blank? && @lat.blank? && @long.blank?
      if ::Geocodr.valid?(@address_string) && (response = ::Geocodr.find(@address_string)).present?
        @long, @lat = response.first['geometry']['coordinates']
      end
      self.position = "POINT(#{@long} #{@lat})"
    end

    def detailed_status=(value)
      unless value.in?(Citysdk::Status::PERMISSABLE_CITYSDK_KEYS | [detailed_status])
        errors.add :status, :invalid
        raise ActiveRecord::RecordInvalid, self
      end
      return if (new_status = Citysdk::Status::CITYSDK_WRITE[value]).blank?
      self.status = new_status
    end

    def priority=(value)
      unless Issue.priorities.value?(value.to_i)
        errors.add :priority, :invalid
        raise ActiveRecord::RecordInvalid, self
      end
      super(value.to_i)
    end

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

    def media=(value)
      tempfile = Tempfile.new('fileupload')
      tempfile.binmode
      tempfile.write(Base64.decode64(value))
      tempfile.close

      filename = 'filename.jpg'
      mime_type = Mime::Type.lookup_by_extension(File.extname(filename)[1..]).to_s
      self.new_photo = ActionDispatch::Http::UploadedFile.new(tempfile:, filename:, type: mime_type)
      self.photo_requested = false
    end
  end
end
