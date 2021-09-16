# frozen_string_literal: true

class CountyGroup < Group
  belongs_to :county, foreign_key: :reference_id, inverse_of: :groups

  private

  def reference_name
    county.to_s with_model_name: false
  end
end
