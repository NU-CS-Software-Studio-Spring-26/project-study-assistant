class User < ApplicationRecord
  has_secure_password validations: false
  has_many :assignments, dependent: :destroy
  has_many :created_study_groups, class_name: "StudyGroup", foreign_key: :creator_id, inverse_of: :creator, dependent: :destroy
  has_many :group_memberships, dependent: :destroy
  has_many :study_groups, through: :group_memberships
  has_many :study_group_messages, dependent: :destroy

  normalizes :email, with: ->(email) { email.to_s.strip.downcase }
  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, format: { with: /\A[^@]+@(u\.northwestern\.edu|northwestern\.edu)\z/, message: "must be a Northwestern email (@northwestern.edu or @u.northwestern.edu)" }, unless: :google_user?
  validates :password, presence: true, on: :create, unless: :google_user?

  def google_user?
    provider == "google_oauth2"
  end

  def self.from_google(auth)
    user = find_or_initialize_by(email: auth.info.email)
    user.name = auth.info.name if user.name.blank?
    user.provider = auth.provider
    user.uid = auth.uid
    user.google_token = auth.credentials.token
    user.password = SecureRandom.hex(20) if user.new_record?
    user.save!
    user
  end
end