# frozen_string_literal: true

class EditorialsController < ApplicationController
  def show
    @editorial_criteria = EditorialSettings::Config.levels
    @editorial_notifications = EditorialNotification.includes(:user).references(:user)
      .order(user_arel_table[:last_name], user_arel_table[:first_name])
  end
end
