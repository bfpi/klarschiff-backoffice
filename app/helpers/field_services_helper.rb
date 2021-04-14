# frozen_string_literal: true

module FieldServicesHelper
  def operators_list(group)
    safe_join group.field_service_operators.map(&:to_s), tag.br
  end
end
