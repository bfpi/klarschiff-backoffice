# frozen_string_literal: true

module StringRepresentationWithOptionalModelName
  extend ActiveSupport::Concern

  def to_s(with_model_name: false)
    return name unless with_model_name
    [model_name.human, name].join ' '
  end
end
