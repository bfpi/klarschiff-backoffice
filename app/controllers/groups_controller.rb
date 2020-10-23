# frozen_string_literal: true

class GroupsController < ApplicationController
  def index
    @groups = Group.active.order(:short_name).page(params[:page] || 1).per(params[:per_page] || 20)
  end

  def edit
    @group = Group.find(params[:id])
  end

  def new
    @group = Group.new
  end

  def update
    @group = Group.find(params[:id])
    if @group.update(group_params) && params[:save_and_close].present?
      redirect_to action: :index
    else
      render :edit
    end
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
      render :new
    end
  end

  private

  def group_params
    params.require(:group).permit(:active, :name, :short_name, :kind, :email, :user_id, :instance)
  end
end
