# frozen_string_literal: true

class UserLdapsController < ApplicationController
  def index
    render json: Ldap.search(params[:term]).map { |l| { value: l['myhash']['dn'].first, label: "#{l['myhash']['cn'].first} (#{l['myhash']['uid'].first})" } }
  end
end
