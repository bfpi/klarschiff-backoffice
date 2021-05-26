# frozen_string_literal: true

class Issue < ApplicationRecord
  include DateTimeAttributesWithBooleanAccessor
  include Issue::Callbacks
  include Issue::Icons
  include Issue::Scopes
  include Logging

  attr_accessor :responsibility_action, :new_photo

  with_options _prefix: true do
    enum description_status: { internal: 0, external: 1, deleted: 2 }
    enum priority: { low: 0, middle: 1, high: 2 }
    enum status: { pending: 0, received: 1, reviewed: 2, in_process: 3, not_solvable: 4, duplicate: 5, closed: 6,
                   deleted: 7 }
    enum trust_level: { external: 0, internal: 1, field_service_team: 2 }
  end

  CLOSED_STATUSES = %i[not_solvable duplicate closed deleted].freeze
  DELEGATION_EXPORT_ATTRIBUTES = %i[id kind created_at main_category sub_category status address priority].freeze
  EXPORT_ATTRIBUTES = %i[id kind created_at updated_at main_category sub_category status address district
                         supporters group delegation priority].freeze

  mattr_reader :delegation_statuses do
    statuses.slice('in_process', 'closed')
  end

  belongs_to :category
  belongs_to :delegation, optional: true, class_name: 'Group'
  belongs_to :group
  belongs_to :job, optional: true

  with_options dependent: :destroy do
    has_many :abuse_reports
    has_many :all_log_entries, -> { includes(:auth_code, :user) }, class_name: 'LogEntry', inverse_of: :issue
    has_many :comments
    has_many :feedbacks
    has_many :photos, -> { order(:created_at) }, inverse_of: :issue
    has_many :supporters
  end

  accepts_nested_attributes_for :photos, allow_destroy: true

  delegate :group_id, :date, to: :job, prefix: true, allow_nil: true
  delegate :kind, :kind_name, to: :category, allow_nil: true
  delegate :main_category, :sub_category, to: :category

  def to_s
    "#{kind_name} ##{id}"
  end

  alias logging_subject_name to_s

  def lat
    position&.y
  end

  def lon
    position&.x
  end

  def as_json(options = {})
    super options.reverse_merge(methods: %i[lat lon map_icon])
  end

  def archived
    archived_at?
  end

  def archived=(date_time)
    self.archived_at = date_time.presence && Time.current
  end

  def job_date=(date)
    return if date.blank?
    self.job = Job.new(status: :unchecked) if job.blank?
    job.date = date
    job.save
  end

  def job_group_id=(group_id)
    return if group_id.blank?
    self.job = Job.new(status: :unchecked) if job.blank?
    job.group = Group.find(group_id)
    job.save
  end

  def latest_entry
    all_log_entries.order(created_at: :desc).find_by table: 'issue'
  end
end
