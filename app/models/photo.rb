# frozen_string_literal: true

require 'mini_magick'

class Photo < ApplicationRecord
  include Logging

  enum status: { internal: 0, external: 1, deleted: 2 }, _prefix: true

  belongs_to :issue
  has_one_attached :file

  attr_accessor :censor_rectangles, :censor_width, :censor_height

  validates :confirmation_hash, presence: true, uniqueness: true
  validates :file, presence: true

  before_validation :set_confirmation_hash, on: :create

  def _modification
    nil
  end

  def _modification=(value)
    return if value.blank?
    case value
    when 'rotate'
      rotate_image
    when 'censor'
      censor_image
    end
  end

  private

  def current_image
    new_image = MiniMagick::Image.read(file.download)
    new_image.auto_orient
  end

  def save_modified_image(new_image)
    new_filename = file.filename
    new_content_type = file.content_type
    file.purge
    file.attach(io: File.open(new_image.path), filename: new_filename, content_type: new_content_type)
  end

  def censor_image
    new_image = current_image

    width = new_image.data['geometry']['width']
    height = new_image.data['geometry']['height']
    censor_rectangles.split(';').each do |rectangle|
      new_image.mogrify do |m|
        m << '-draw' << calculate_rectangle(rectangle, width, height)
      end
    end

    reset_censor_settings
    save_modified_image(new_image)
  end

  def calculate_rectangle(rectangle, width, height)
    x0, y0, x1, y1 = rectangle.split(',').map(&:to_f)
    (x0 = (x0 * width) / censor_width.to_f)
    (y0 = (y0 * height) / censor_height.to_f)
    (x1 = x0 + (x1 * width) / censor_width.to_f)
    (y1 = y0 + (y1 * height) / censor_height.to_f)
    "rectangle #{x0},#{y0} #{x1},#{y1}"
  end

  def reset_censor_settings
    self.censor_rectangles = nil
    self.censor_width = nil
    self.censor_height = nil
  end

  def rotate_image
    new_image = current_image
    new_image = new_image.rotate 90
    save_modified_image(new_image)
  end

  def set_confirmation_hash
    self.confirmation_hash = SecureRandom.uuid
  end
end
