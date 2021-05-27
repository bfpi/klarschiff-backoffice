# frozen_string_literal: true

class EditorialNotificationsController < ApplicationController
  before_action { check_auth :manage_editorial_notifications }

  def index
    @editorial_criteria = EditorialSettings::Config.levels
    @editorial_notifications = paginate(base_collection)
  end

  def new
    @editorial_notification = EditorialNotification.new
  end

  def create
    @editorial_notification = EditorialNotification.new editorial_notification_params
    if @editorial_notification.save
      if params[:save_and_close].present?
        redirect_to action: :index
      else
        render :edit
      end
    else
      render :new
    end
  end

  def edit
    @editorial_notification = EditorialNotification.find(params[:id])
  end

  def update
    @editorial_notification = EditorialNotification.find(params[:id])
    if @editorial_notification.update(editorial_notification_params) && params[:save_and_close].present?
      redirect_to action: :index
    else
      render :edit
    end
  end

  def destroy
    editorial_notification = EditorialNotification.find(params[:id])
    editorial_notification.destroy
    redirect_to action: :index
  end

  private

  def base_collection
    EditorialNotification.includes(user: %i[groups_users groups]).references(user: %i[groups_users groups])
      .order(*order_attributes)
  end

  def order_attributes
    [User.arel_table[:last_name], User.arel_table[:first_name], EditorialNotification.arel_table[:level]]
  end

  def editorial_notification_params
    params.require(:editorial_notification).permit(:user_id, :level, :repetition)
  end

  def paginate(collection)
    collection.page(params[:page] || 1).per(params[:per_page] || 10)
  end
end
