# frozen_string_literal: true

class Issue < ApplicationRecord
  include Logging

  belongs_to :category
  belongs_to :delegation
  belongs_to :group
  belongs_to :job, optional: true
  belongs_to :responsibility

  with_options dependent: :destroy do
    has_many :abuse_report
    has_many :comment
    has_many :feedback
    has_many :log_entries
    has_many :photo
    has_many :supporter
  end

  with_options _prefix: true do
    enum description_status: { internal: 0, external: 1, deleted: 2 }
    enum kind: { idea: 0, problem: 1, hint: 2 }
    enum priority: { low: 0, middle: 1, high: 2 }
    enum status: { pending: 0, open: 1, in_process: 2, duplicate: 3, deleted: 4, not_solvable: 5, closed: 6 }
    enum trust_level: { external: 0, internal: 1, field_service_team: 2 }
  end

  validates :confirmation_hash, presence: true, uniqueness: true

  private

  def set_confirmation_hash
    self.confirmation_hash = SecureRandom.uuid
  end
end
