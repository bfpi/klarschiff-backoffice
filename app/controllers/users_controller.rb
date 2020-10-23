# frozen_string_literal: true

class UsersController < ApplicationController
  def index
    @users = User.active.order(:login).page(params[:page] || 1).per(params[:per_page] || 20)
  end

  def edit
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params) && params[:save_and_close].present?
      redirect_to action: :index
    else
      render :edit
    end
  end

  def create
    @user = User.new user_params
    if @user.save
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

  def user_params
    params.require(:user).permit(:active, :role, :first_name, :last_name, :login, :ldap, :email, :group_feedback_recipient)
  end
end
