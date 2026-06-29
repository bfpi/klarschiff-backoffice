# frozen_string_literal: true

class MissionControlBaseController < ApplicationController
  before_action { check_auth :manage_jobs }
end
