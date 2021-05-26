# frozen_string_literal: true

module EditorialNotificationsHelper
  def levels
    EditorialSettings::Config.levels.pluck(:level)
  end
end
