# frozen_string_literal: true

class UsersController < ApplicationController
  include Filter

  def index
    users = filter(User.authorized).order(:login)
    respond_to do |format|
      format.html { @users = users.page(params[:page] || 1).per(params[:per_page] || 20) }
      format.json { render json: users }
    end
  end

  def edit
    @user = User.authorized.find(params[:id])
  end

  def new
    @user = User.new
  end

  def update
    @user = User.authorized.find(params[:id])
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
    params.require(:user).permit(:active, :role, :first_name, :last_name, :login, :ldap, :email,
      :group_feedback_recipient, group_ids: [])
  end

  def filter_name_columns
    %i[first_name last_name login]
  end
end
