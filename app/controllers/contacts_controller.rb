# frozen_string_literal: true

class ContactsController < ApplicationController
  skip_before_action :authenticate

  def show; end
end
