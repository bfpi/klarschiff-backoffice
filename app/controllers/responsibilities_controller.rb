# frozen_string_literal: true

class ResponsibilitiesController < ApplicationController
  include Filter
  include Sorting

  before_action { check_auth :manage_responsibilities }

  helper_method :permitted_order_and_pagination_params

  def index
    @categories = filter(Category.active).order(order_attr).page(params[:page] || 1).per(params[:per_page] || 20)
    @responsibilities = result_list_responsibilities
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
      return redirect_to permitted_order_and_pagination_params.merge(action: :index) if params[:save_and_close].present?
      return render :edit
    end
    render :new
  end

  def update
    @responsibility = Responsibility.authorized.find(params[:id])
    if @responsibility.update(responsibility_params) && params[:save_and_close].present?
      return redirect_to permitted_order_and_pagination_params.merge(action: :index)
    end
    render :edit
  end

  def destroy
    @responsibility = Responsibility.authorized.find(params[:id])
    @responsibility.update!(deleted_at: Time.current)
    redirect_to permitted_order_and_pagination_params.merge(action: :index)
  end

  private

  def permitted_order_and_pagination_params
    params.permit :page, order_by: %i[column dir]
  end

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

  def result_list_responsibilities
    filter(Responsibility.includes(:group, { category: %i[main_category sub_category] })
      .authorized.active).order(order_attr).page(params[:page] || 1).per(params[:per_page] || 20)
  end
end
