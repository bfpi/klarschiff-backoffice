# frozen_string_literal: true

class FieldServicesController < ApplicationController
  include Filter
  before_action { check_auth :manage_field_service }

  def index
    field_services = filter(groups).includes(:field_service_operator).order(:short_name)

    respond_to do |format|
      format.html { @field_services = field_services.page(params[:page] || 1).per(params[:per_page] || 20) }
      format.json { render json: field_services }
    end
  end

  def edit
    @field_service = groups.find(params[:id])
  end

  def update
    @field_service = groups.find(params[:id])
    if @field_service.update(field_service_params) && params[:save_and_close].present?
      redirect_to action: :index
    else
      render :edit
    end
  end

  private

  def groups
    Group.active.where(kind: :field_service_team)
  end

  def field_service_params
    params.require(:group).permit(field_service_operator_ids: [])
  end

  def filter_name_columns
    %i[pattern source reason]
  end
end
