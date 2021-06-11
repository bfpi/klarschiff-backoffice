# frozen_string_literal: true

module Citysdk
  class Request
    module Media
      extend ActiveSupport::Concern

      delegate :rails_blob_path, to: 'Rails.application.routes.url_helpers'

      def media_url
        return nil unless photos.status_external.first
        [config[:media_base_url], rails_blob_path(photos.first.file, only_path: true)].join
      end

      def media_urls
        return nil if photos.status_external.blank?
        photos.status_external.map do |photo|
          [config[:media_base_url], rails_blob_path(photo.file, only_path: true)].join
        end
      end
    end
  end
end
