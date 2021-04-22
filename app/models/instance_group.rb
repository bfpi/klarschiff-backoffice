# frozen_string_literal: true

class InstanceGroup < Group
  belongs_to :instance, foreign_key: :reference_id, inverse_of: :groups
end
