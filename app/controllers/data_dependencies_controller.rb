# frozen_string_literal: true

class DataDependenciesController < ApplicationController
  def update
    @attribute = params[:attribute]
    @value = params[:value]
  end
end
