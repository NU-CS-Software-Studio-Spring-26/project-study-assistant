class User < ApplicationRecord
  has_secure_password

  has_many :assignments, dependent: :destroy
  has_many :created_study_groups, class_name: "StudyGroup", foreign_key: :creator_id, inverse_of: :creator, dependent: :destroy
  has_many :group_memberships, dependent: :destroy
  has_many :study_groups, through: :group_memberships
  has_many :study_group_messages, dependent: :destroy

  normalizes :email, with: ->(email) { email.to_s.strip.downcase }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
end
