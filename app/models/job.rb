# frozen_string_literal: true

class Job < ApplicationRecord
  include Logging

  enum status: { unchecked: 0, checked: 1, uncheckable: 2 }, _prefix: true

  has_one :issue, dependent: :nullify
  belongs_to :group, -> { where(kind: :field_service_team) }, inverse_of: :jobs

  validates :status, :date, presence: true

  before_validation :set_order, on: :create

  scope :by_order, -> { order(:order, :created_at) }

  self.omit_field_log |= %w[order]

  def self.citysdk_statuses
    { unchecked: 'UNCHECKED', checked: 'CHECKED', uncheckable: 'NOT_CHECKABLE' }
  end

  def self.group_by_user_group(job_date)
    Job.where(group: Current.user&.field_service_teams, date: job_date).group_by(&:group)
  end

  def status_color
    return if status_uncheckable?
    " text-#{status_checked? ? 'success' : 'danger'}"
  end

  def to_s
    model_name.human
  end

  private

  def set_order
    self.order = Job.where(group:, date:).order(:order).pluck(:order).last.to_i + 1
  end
end
