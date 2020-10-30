# frozen_string_literal: true

class Issue < ApplicationRecord
  include Logging

  with_options _prefix: true do
    enum description_status: { internal: 0, external: 1, deleted: 2 }
    enum kind: { idea: 0, problem: 1, hint: 2 }
    enum priority: { low: 0, middle: 1, high: 2 }
    enum status: { pending: 0, open: 1, in_process: 2, duplicate: 3, deleted: 4, not_solvable: 5, closed: 6 }
    enum trust_level: { external: 0, internal: 1, field_service_team: 2 }
  end

  belongs_to :category
  belongs_to :delegation, optional: true, class_name: 'Group'
  belongs_to :job, optional: true
  belongs_to :responsibility, class_name: 'Group'

  with_options dependent: :destroy do
    has_many :abuse_report
    has_many :all_log_entries, class_name: 'LogEntry'
    has_many :comment
    has_many :feedback
    has_many :photo
    has_many :supporter
  end

  validates :kind, :position, :status, presence: true
  validates :confirmation_hash, uniqueness: true

  before_validation :set_confirmation_hash, on: :create
  before_validation :set_responsibility, on: :create
  before_save :set_expected_closure, if: :status_changed?

  def to_s
    "#{ Issue.human_enum_name(:kind, kind)} ##{ id }"
  end

  def icon
    "icons/map/active/png/#{category&.kind || 'blank'}-#{icon_color}.png"
  end

  private

  def icon_color
    case status
    when :in_progress
      'yellow'
    when :pending
      'gray'
    else
      'gray'
    end
  rescue StandardError
    'gray'
  end

  def set_confirmation_hash
    self.confirmation_hash = SecureRandom.uuid
  end

  def set_responsibility
    self.responsibility = category&.group
  end

  def set_expected_closure
    self.expected_closure = status_in_process? ? Time.zone.today + category.average_turnaround_time.days : nil
  end
end
