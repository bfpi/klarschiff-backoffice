# frozen_string_literal: true

class FillResponsibilitiesController < ApplicationController
  before_action { check_auth :manage_responsibilities }

  include ResponsibilitiesHelper

  def new
    @responsibility = Responsibility.new
  end

  def create
    Responsibility.transaction do
      missing_categories.each do |cat|
        @responsibility = Responsibility.new(responsibility_params.merge(category: cat))
        raise ActiveRecord::Rollback unless @responsibility.save
      end
      return redirect_to responsibilities_path
    end
    render :new, status: :unprocessable_entity
  end

  private

  def responsibility_params
    return {} if params[:responsibility].blank?
    params.require(:responsibility).permit(:group_id)
  end
end
