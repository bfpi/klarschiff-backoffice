# frozen_string_literal: true

class CensorRectangle
  def initialize(string)
    @x0, @y0, @x1, @y1 = string.split(',').map(&:to_f)
  end

  def calculate(width, height, censor_width, censor_height)
    cw, ch = [censor_width, censor_height].map(&:to_f)
    x0 = @x0 * width / cw
    y0 = @y0 * height / ch
    x1 = x0 + (@x1 * width / cw)
    y1 = y0 + (@y1 * height / ch)
    "rectangle #{x0},#{y0} #{x1},#{y1}"
  end
end
