# frozen_string_literal: true

module Citysdk
  class Request
    module Media
      extend ActiveSupport::Concern

      delegate :rails_blob_path, to: 'Rails.application.routes.url_helpers'

      def media_url
        return unless (photo = photos.status_external.first)
        [config[:media_base_url], rails_blob_path(photo.file, only_path: true)].join
      end

      def media_urls
        return unless photos.status_external.exists?
        photos.status_external.map do |photo|
          [config[:media_base_url], rails_blob_path(photo.file, only_path: true)].join
        end
      end
    end
  end
end
