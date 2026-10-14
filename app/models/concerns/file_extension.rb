# frozen_string_literal: true

module FileExtension
  extend ActiveSupport::Concern

  def extension(tempfile)
    mime = Marcel::MimeType.for(tempfile)
    ext = MiniMime.lookup_by_content_type(mime)&.extension
    ext = 'jpg' if ext == 'jpeg'
    ext
  end
end
