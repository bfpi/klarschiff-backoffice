# frozen_string_literal: true

class HelpsController < ApplicationController
  skip_before_action :authenticate

  def show; end
end
