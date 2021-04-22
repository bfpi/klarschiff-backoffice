# frozen_string_literal: true

class AuthorityGroup < Group
  belongs_to :authority, foreign_key: :reference_id, inverse_of: :groups
end
