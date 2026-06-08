class StudyGroup < ApplicationRecord
  MAX_ACTIVE_GROUPS = 128
  LOCATION_MODES = [ "Online", "In Person" ].freeze
  COMMUNICATION_STYLES = [ "Quiet", "Talkative", "Balanced" ].freeze

  belongs_to :creator, class_name: "User", inverse_of: :created_study_groups

  has_many :group_memberships, dependent: :destroy
  has_many :members, through: :group_memberships, source: :user
  has_many :study_group_messages, dependent: :destroy

  before_validation :sync_legacy_study_time

  validates :name, presence: true, length: { maximum: 150 }
  validates :description, length: { maximum: 2000 }, allow_blank: true
  validate :tags_within_limits

  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :start_time_must_be_in_the_future
  validate :end_time_must_be_after_start_time
  validate :active_group_limit, on: :create
  validates :location_mode, inclusion: { in: LOCATION_MODES }
  validates :communication_style, inclusion: { in: COMMUNICATION_STYLES }
  validates :join_password, length: { maximum: 128 }, allow_blank: true

  scope :keyword_search, ->(query) do
    next all if query.blank?

    term = "%#{sanitize_sql_like(query.strip)}%"
    where(
      "study_groups.name ILIKE :term OR study_groups.location_mode ILIKE :term OR study_groups.communication_style ILIKE :term OR EXISTS (SELECT 1 FROM unnest(study_groups.tags) AS tag WHERE tag ILIKE :term)",
      term: term
    )
  end

  def password_protected?
    join_password.present?
  end

  def all_tags
    normalized_tags = tags.to_a.reject(&:blank?)
    [ location_mode, communication_style, *normalized_tags ].uniq
  end

  private

  def sync_legacy_study_time
    self.study_time = start_time if has_attribute?(:study_time) && study_time.blank? && start_time.present?
  end

  def tags_within_limits
    return if tags.blank?
    if tags.size > 20
      errors.add(:tags, "cannot have more than 20 tags")
    end
    if tags.any? { |t| t.to_s.length > 50 }
      errors.add(:tags, "each tag must be under 50 characters")
    end
  end

  def start_time_must_be_in_the_future
    return if start_time.blank?
    return if start_time >= Time.current

    errors.add(:start_time, "must be in the future")
  end

  def end_time_must_be_after_start_time
    return if start_time.blank? || end_time.blank?
    return if end_time > start_time

    errors.add(:end_time, "must be after the start time")
  end

  def active_group_limit
    return unless new_record?

    active_count = StudyGroup.where("end_time >= ? OR end_time IS NULL", Time.current).count
    if active_count >= MAX_ACTIVE_GROUPS
      errors.add(:base, "Maximum number of active study groups (#{MAX_ACTIVE_GROUPS}) reached. Please try again later.")
    end
  end
end
