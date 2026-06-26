# frozen_string_literal: true

Rails.application.config.to_prepare do
  MissionControl::Jobs::ApplicationController.class_eval do
    include Authorization

    before_action { check_auth :manage_jobs }
  end
end
