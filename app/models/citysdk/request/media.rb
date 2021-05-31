# frozen_string_literal: true

module Citysdk
  class Request
    module Media
      extend ActiveSupport::Concern

      delegate :rails_blob_path, to: ActionView::Helpers::UrlHelper

      def media_url
        return nil unless photos.first
        [Rails.application.config.root_url, rails_blob_path(photos.first.file, only_path: true)].join
      end

      def media_urls
        return nil if photos.blank?
        photos.map do |photo|
          [Rails.application.config.root_url, rails_blob_path(photo.file, only_path: true)].join
        end
      end
    end
  end
end
