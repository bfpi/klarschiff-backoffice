# frozen_string_literal: true

Rails.application.reloader.to_prepare do
  if Rails.application.config.action_mailer.show_previews
    require 'rails/mailers_controller'

    module Rails
      class MailersController
        include ArelTable
        include Authorization

        before_action { check_auth :manage_mail_templates }

        append_view_path 'app/views'
      end
    end
  end
end
