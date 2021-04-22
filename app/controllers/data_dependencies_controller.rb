# frozen_string_literal: true

class DataDependenciesController < ApplicationController
  helper IssuesHelper

  def update
    @attribute = params[:attribute]
    @value = params[:value]
  end
end
