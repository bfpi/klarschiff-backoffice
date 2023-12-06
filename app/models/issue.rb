# frozen_string_literal: true

class Issue < ApplicationRecord
  include DateTimeAttributesWithBooleanAccessor
  include Issue::Callbacks
  include Issue::Getters
  include Issue::Icons
  include Issue::Scopes
  include Logging

  attr_accessor :new_photo, :responsibility_action, :responsibility_already_set

  self.omit_field_log += %w[updated_by_auth_code_id updated_by_user_id]

  with_options _prefix: true do
    enum description_status: { internal: 0, external: 1, deleted: 2 }
    enum priority: { low: 0, middle: 1, high: 2 }
    enum status: { pending: 0, received: 1, reviewed: 2, in_process: 3, not_solvable: 4, duplicate: 5, closed: 6,
                   deleted: 7 }
    enum trust_level: { external: 0, internal: 1, field_service_team: 2 }
  end

  CLOSED_STATUSES = %i[not_solvable duplicate closed deleted].freeze
  DELEGABLE_STATUSES = %i[in_process not_solvable duplicate closed].freeze
  DELEGATION_EXPORT_ATTRIBUTES = %i[id created_at kind main_category sub_category
                                    status address updated_at priority].freeze
  EXPORT_ATTRIBUTES = %i[id created_at kind main_category sub_category status address district
                         supporters group delegation updated_at updated_by_user priority].freeze

  mattr_reader :delegation_statuses do
    statuses.slice('in_process', 'closed')
  end

  belongs_to :category
  belongs_to :delegation, optional: true, class_name: 'Group'
  belongs_to :group
  belongs_to :job, optional: true
  belongs_to :updated_by_auth_code, optional: true, class_name: 'AuthCode'
  belongs_to :updated_by_user, optional: true, class_name: 'User'

  with_options dependent: :destroy do
    has_many :abuse_reports
    has_many :all_log_entries, -> { includes(:auth_code, :user) }, class_name: 'LogEntry', inverse_of: :issue
    has_many :comments
    has_many :completions, inverse_of: :issue
    has_many :feedbacks
    has_many :photos, -> { order(:created_at) }, inverse_of: :issue
    has_many :external_photos, -> { status_external.order(:created_at) }, class_name: 'Photo', inverse_of: :issue
    has_many :supporters
  end

  accepts_nested_attributes_for :photos, allow_destroy: true

  delegate :group_id, :date, to: :job, prefix: true, allow_nil: true
  delegate :kind, :kind_name, to: :category, allow_nil: true
  delegate :main_category, :sub_category, to: :category, allow_nil: true
  delegate :dms, to: :sub_category, allow_nil: true

  alias logging_subject_name to_s

  def as_json(options = {})
    super(options.reverse_merge(only: :id, methods: %i[lat lon map_icon]))
  end

  def archived=(value)
    self.archived_at = value.to_i.positive? ? Time.current : 0
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

  def external_position
    return @external_position if @external_position
    point = self.class.connection.select_value(
      "SELECT ST_AsText(ST_Transform(ST_GeomFromText('#{position}', 4326), 25833)) AS point"
    )
    factory = RGeo::Cartesian.preferred_factory(srid: 25_833)
    @external_position = factory.parse_wkt(point)
  end

  def responsibility_since
    return if group.blank?
    all_log_entries.order(created_at: :desc).find_by(attr: :group)&.created_at || reviewed_at
  end

  def status_since
    return created_at if all_log_entries.where(attr: :status).blank?
    all_log_entries.order(created_at: :desc).find_by(attr: :status, new_value: status)&.created_at
  end

  def district
    District.find_by('ST_Contains(area, ?)', position)
  end

  def default_group_without_gui_access?
    !Settings::Instance.auth_code_gui_access_for_external_participants && group&.reference_default
  end
end
