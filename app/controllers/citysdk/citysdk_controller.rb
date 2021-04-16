# frozen_string_literal: true

module Citysdk
  class CitysdkController < ApplicationController
    include CitysdkResponder
    include CitysdkParameterValidation
    skip_before_action :verify_authenticity_token
  end
end
