# frozen_string_literal: true

module Citysdk
  class Request
    module Media
      extend ActiveSupport::Concern

      delegate :rails_blob_path, to: 'Rails.application.routes.url_helpers'

      def media_url
        return unless (photo = external_photos.first)
        resized_url(photo.file)
      end

      def media_urls
        return if external_photos.empty? # use eager loaded relation instead of AR exist / count
        external_photos.map do |photo|
          resized_url(photo.file)
        end
      end

      private

      def resized_url(file)
        [config[:media_base_url], Rails.application.routes.url_helpers.rails_representation_url(
          file.variant(resize_to_limit: [360, 360]), only_path: true
        )].join
      end
    end
  end
end
