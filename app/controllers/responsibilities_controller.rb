# frozen_string_literal: true

class ResponsibilitiesController < ApplicationController
  include Filter
  include Sorting
  before_action { check_auth :manage_responsibilities }

  def index
    @categories = filter(Category.active).order(order_attr).page(params[:page] || 1).per(params[:per_page] || 20)
    @responsibilities = filter(Responsibility.includes(:group, { category: %i[main_category sub_category] })
      .authorized.active).order(order_attr).page(params[:page] || 1).per(params[:per_page] || 20)
  end

  def new
    @responsibility = Responsibility.new(params.permit(:category_id))
  end

  def edit
    @responsibility = Responsibility.authorized.find(params[:id])
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

  def update
    @responsibility = Responsibility.authorized.find(params[:id])
    if @responsibility.update(responsibility_params) && params[:save_and_close].present?
      redirect_to action: :index
    else
      render :edit
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

  def custom_order(col, dir)
    case col.to_sym
    when :kind
      main_category_arel_table[:kind].send(dir)
    when :category
      [main_category_arel_table[:name].send(dir), sub_category_arel_table[:name].send(dir)]
    when :group
      group_arel_table[:name].send(dir)
    end
  end

  def default_order
    [main_category_arel_table[:kind], main_category_arel_table[:name], sub_category_arel_table[:name]]
  end
end
