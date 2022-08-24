# frozen_string_literal: true

class EditorialsController < ApplicationController
  def show
    @editorial_criteria = EditorialSettings::Config.levels
    @editorial_notifications = EditorialNotification.includes(:user).references(:user)
      .order(user_at[:last_name], user_at[:first_name])
  end
end
