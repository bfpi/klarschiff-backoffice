# frozen_string_literal: true

class PlacesController < ApplicationController
  def index
    return [] if (pattern = params[:pattern]).blank?
    render json: Geocodr.search_places(pattern).to_json
  end

  def show
    issue = Issue.new
    issue.assign_attributes(params.require(:issue).permit(:position))
    issue.send(:update_address_parcel_property_owner)
    respond_to do |format|
      format.json { address_response(issue) }
    end
  end

  private

  def address_response(issue)
    external_coords = I18n.t(
      'issues.external_map.coordinates', x: issue.lon_external&.round, y: issue.lat_external&.round
    )
    json_response = { address: issue.address, parcel: issue.parcel, property_owner: issue.property_owner,
                      external_coords: }
    render json: json_response, status: :ok
  end
end
