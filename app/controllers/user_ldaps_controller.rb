# frozen_string_literal: true

class UserLdapsController < ApplicationController
  def index
    render json: format(Ldap.search(params[:term]))
  end

  def format(response)
    response.map do |l|
      hsh = l['myhash']
      {
        value: hsh[Settings::Ldap.user_identifier]&.first,
        label: format_label(hsh),
        first_name: hsh[Settings::Ldap.user_first_name]&.first,
        last_name: hsh[Settings::Ldap.user_last_name]&.first,
        email: hsh[Settings::Ldap.user_email]&.first
      }
    end
  end

  def format_label(elem)
    "#{elem[Settings::Ldap.user_display_name]&.first} (#{
                     elem[Settings::Ldap.user_identifier]&.first})"
  end
end
