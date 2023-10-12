# frozen_string_literal: true

class GroupsController < ApplicationController
  include Filter
  include Sorting
  before_action { check_auth :manage_groups }

  def index
    groups = filter(Group.authorized).order(order_attr)

    respond_to do |format|
      format.html { @groups = groups.page(params[:page] || 1).per(params[:per_page] || 20) }
      format.json { render json: groups }
    end
  end

  def new
    @group = Current.user.permitted_group_types.first.constantize.new
  end

  def edit
    @group = Group.authorized.find(params[:id])
  end

  def create
    @group = Group.new group_params
    if @group.save
      if params[:save_and_close].present?
        redirect_to action: :index
      else
        render :edit
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @group = Group.authorized.find(params[:id])
    if @group.update(group_params) && params[:save_and_close].present?
      redirect_to action: :index
    else
      render :edit
    end
  end

  private

  def filter(collection)
    filter_include_inactive super(collection)
  end

  def group_params
    params.require(:group).permit(:active, :name, :short_name, :type, :kind, :email, :main_user_id, :reference_default,
      :reference_id, user_ids: [])
  end

  def filter_name_columns
    %i[name short_name]
  end

  def default_order
    :name
  end
end
