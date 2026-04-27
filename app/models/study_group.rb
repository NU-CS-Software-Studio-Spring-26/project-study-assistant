class StudyGroup < ApplicationRecord
  LOCATION_MODES = [ "Online", "In Person" ].freeze
  COMMUNICATION_STYLES = [ "Quiet", "Talkative", "Balanced" ].freeze

  belongs_to :creator, class_name: "User", inverse_of: :created_study_groups

  has_many :group_memberships, dependent: :destroy
  has_many :members, through: :group_memberships, source: :user
  has_many :study_group_messages, dependent: :destroy

  validates :name, presence: true
  validates :study_time, presence: true
  validates :location_mode, inclusion: { in: LOCATION_MODES }
  validates :communication_style, inclusion: { in: COMMUNICATION_STYLES }
  validates :join_password, length: { maximum: 128 }, allow_blank: true

  def password_protected?
    join_password.present?
  end

  def all_tags
    normalized_tags = tags.to_a.reject(&:blank?)
    [ location_mode, communication_style, *normalized_tags ].uniq
  end
end