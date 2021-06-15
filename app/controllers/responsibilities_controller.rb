# frozen_string_literal: true

class ResponsibilitiesController < ApplicationController
  before_action { check_auth :manage_responsibilities }

  def index
    @responsibilities = Responsibility.includes(:group, { category: %i[main_category sub_category] }).authorized.active
      .order(MainCategory.arel_table[:kind], MainCategory.arel_table[:name], SubCategory.arel_table[:name])
      .page(params[:page] || 1).per(params[:per_page] || 20)
  end

  def new
    @responsibility = Responsibility.new
  end

  def edit
    @responsibility = Responsibility.authorized.find(params[:id])
  end

  def update
    @responsibility = Responsibility.authorized.find(params[:id])
    if @responsibility.update(responsibility_params) && params[:save_and_close].present?
      redirect_to action: :index
    else
      render :edit
    end
  end

  def create
    @responsibility = Responsibility.new(responsibility_params)
    if @responsibility.save
      return redirect_to action: :index if params[:save_and_close].present?
      render :edit
    else
      render :new
    end
  end

  def destroy
    @responsibility = Responsibility.authorized.find(params[:id])
    @responsibility.update!(deleted_at: Time.current)
    redirect_to action: :index
  end

  private

  def responsibility_params
    return {} if params[:responsibility].blank?
    params.require(:responsibility).permit(:group_id, :category_id)
  end
end
