# frozen_string_literal: true

class DistrictsController < ApplicationController
  include Filter

  def index
    districts = filter(District.authorized).order(:name)
    respond_to do |format|
      format.json { render json: districts }
    end
  end

  private

  def filter_name_columns
    %i[name]
  end
end
