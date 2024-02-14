# frozen_string_literal: true

class UsersController < ApplicationController
  include Filter
  include Sorting

  before_action(except: %i[change_password update_password]) { check_auth :manage_users }

  def index
    users = filter(User.authorized).unscope(:order).order(order_attr)
    respond_to do |format|
      format.html { @users = users.page(params[:page] || 1).per(params[:per_page] || 20) }
      format.json { render json: users }
    end
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.authorized.find(params[:id])
  end

  def change_password
    check_auth :change_password
    @user = Current.user
  end

  def update_password
    check_auth :change_password
    @user = Current.user
    @success = t(:update_password_success) if @user.update(user_params(password_only: true))
    render :change_password
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

  def update
    @user = User.authorized.find(params[:id])
    if @user.update(user_params) && params[:save_and_close].present?
      redirect_to action: :index
    else
      render :edit
    end
  end

  private

  def filter(collection)
    filter_include_inactive super(collection)
  end

  def user_params(password_only: false)
    return params.require(:user).permit(:password, :password_confirmation) if password_only
    params.require(:user).permit(*permitted_attributes)
  end

  def permitted_attributes
    [:active, :role, :first_name, :last_name, :login, :ldap, :email, :password, :password_confirmation,
     :group_feedback_recipient, :group_responsibility_recipient, { district_ids: [] }, { group_ids: [] }]
  end

  def filter_name_columns
    %i[first_name last_name login]
  end

  def default_order
    %i[last_name first_name login]
  end
end
