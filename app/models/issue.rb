# frozen_string_literal: true

class Issue < ApplicationRecord
  include Logging

  with_options _prefix: true do
    enum description_status: { internal: 0, external: 1, deleted: 2 }
    enum kind: { idea: 0, problem: 1, hint: 2 }
    enum priority: { low: 0, middle: 1, high: 2 }
    enum status: { pending: 0, received: 1, reviewed: 2, in_process: 3, duplicate: 4, deleted: 5, not_solvable: 6,
                   closed: 7 }
    enum trust_level: { external: 0, internal: 1, field_service_team: 2 }
  end

  belongs_to :category
  belongs_to :delegation, optional: true, class_name: 'Group'
  belongs_to :job, optional: true
  belongs_to :responsibility, class_name: 'Group'

  with_options dependent: :destroy do
    has_many :abuse_reports
    has_many :all_log_entries, class_name: 'LogEntry'
    has_many :comments
    has_many :feedback
    has_many :photos, -> { order(:created_at) }, inverse_of: :issue
    has_many :supporters
  end
  accepts_nested_attributes_for :photos, allow_destroy: true

  attr_accessor :responsibility_action, :new_photo

  validates :author, presence: true, on: :create
  validates :description, :kind, :position, :status, presence: true
  validates :confirmation_hash, uniqueness: true
  validates :author, email: true, on: :create

  validate :author_blacklist

  before_validation :add_photo
  before_validation :set_confirmation_hash, on: :create
  before_validation :update_address_parcel_property_owner, if: :position_changed?
  before_validation :set_responsibility
  before_validation :set_reviewed, on: :update
  before_save :set_expected_closure, if: :status_changed?

  def to_s
    "#{Issue.human_enum_name(:kind, kind)} ##{id}"
  end

  def map_icon
    "icons/map/active/png/#{category&.kind || 'blank'}-#{icon_color}.png"
  end

  def list_icon
    "icons/list/png/#{category&.kind || 'blank'}-#{icon_color}-22px.png"
  end

  private

  def author_blacklist
    return if errors[:author].present?
    return unless MailBlacklist.where(pattern: [author, author[author.index('@') + 1..]]).any?
    errors.add :author, :blacklist_pattern
  end

  def icon_color
    case status
    when 'received', 'reviewed'
      'red'
    when 'in_process'
      'yellow'
    else
      'gray'
    end
  end

  def add_photo
    return if new_photo.blank?
    photos.new file: new_photo, author: Current.user.to_s, status: :internal
  end

  def update_address_parcel_property_owner
    self.address = Geocodr.address(self)
    self.parcel = Geocodr.parcel(self)
    self.property_owner = Geocodr.property_owner(self)
  end

  def set_confirmation_hash
    self.confirmation_hash = SecureRandom.uuid
  end

  def set_responsibility
    return if responsibility.present? && responsibility_action.blank?
    case responsibility_action&.to_sym
    when :accept
      self.responsibility_accepted = true
    when :manual
      self.responsibility_accepted = false
    else
      self.responsibility = category&.group
      self.responsibility_accepted = false
    end
  end

  def set_reviewed
    return if reviewed_at.present?
    self.reviewed_at = Time.current
    status_reviewed!
  end

  def set_expected_closure
    self.expected_closure = status_in_process? ? Time.zone.today + category.average_turnaround_time.days : nil
  end
end
