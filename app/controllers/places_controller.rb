# frozen_string_literal: true

class PlacesController < ApplicationController
  def index
    return [] if (pattern = params[:pattern]).blank?
    render json: Geocodr.search_places(pattern).to_json
  end
end
