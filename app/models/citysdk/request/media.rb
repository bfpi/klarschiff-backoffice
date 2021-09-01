# frozen_string_literal: true

module Citysdk
  class Request
    module Media
      extend ActiveSupport::Concern

      delegate :rails_blob_path, to: 'Rails.application.routes.url_helpers'

      def media_url
        return unless (photo = external_photos.first)
        [config[:media_base_url], rails_blob_path(photo.file, only_path: true)].join
      end

      def media_urls
        return if external_photos.empty? # use eager loaded relation instead of AR exist / count
        external_photos.map do |photo|
          [config[:media_base_url], rails_blob_path(photo.file, only_path: true)].join
        end
      end
    end
  end
end
