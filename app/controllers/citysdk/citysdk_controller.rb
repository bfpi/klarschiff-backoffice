# frozen_string_literal: true

module Citysdk
  class CitysdkController < ApplicationController
    include ParameterValidation
    include Responder
    skip_before_action :verify_authenticity_token
    before_action :set_root

    protected

    def set_root
      Rails.application.config.root_url = root_url[0...-1]
    end
  end
end
