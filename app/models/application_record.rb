# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.human_enum_name(enum_name, enum_value)
    I18n.t("enums.#{model_name.i18n_key}.#{enum_name}.#{enum_value}")
  end
end
