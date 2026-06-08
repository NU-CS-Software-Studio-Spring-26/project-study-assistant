class User < ApplicationRecord
  has_secure_password validations: false
  has_many :assignments, dependent: :destroy
  has_many :created_study_groups, class_name: "StudyGroup", foreign_key: :creator_id, inverse_of: :creator, dependent: :destroy
  has_many :group_memberships, dependent: :destroy
  has_many :study_groups, through: :group_memberships
  has_many :study_group_messages, dependent: :destroy
  has_one_attached :avatar

  attr_accessor :accept_terms

  normalizes :email, with: ->(email) { email.to_s.strip.downcase }
  validates :name, presence: true, length: { maximum: 100 }
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, format: { with: /\A[^@]+@(u\.northwestern\.edu|northwestern\.edu)\z/, message: "must be a Northwestern email (@northwestern.edu or @u.northwestern.edu)" }, unless: :google_user?
  validates :password, presence: true, on: :create, unless: :google_user?
  validates :password, length: { minimum: 8 }, on: :create, unless: :google_user?
  validates :password, length: { minimum: 8 }, if: -> { password.present? && persisted? }
  validate :avatar_format_and_size
  validate :terms_must_be_accepted, on: :create

  before_save :stamp_terms_accepted_at

  def google_user?
    provider == "google_oauth2"
  end

  def avatar_format_and_size
    return unless avatar.attached?

    unless avatar.content_type.in?(%w[image/png image/jpeg image/webp])
      errors.add(:avatar, "must be a PNG, JPG, or WebP image")
    end

    if avatar.byte_size > 5.megabytes
      errors.add(:avatar, "must be smaller than 5 MB")
    end
  end

  def self.from_google(auth)
    user = find_or_initialize_by(email: auth.info.email)
    user.name = auth.info.name if user.name.blank?
    user.provider = auth.provider
    user.uid = auth.uid
    user.google_token = auth.credentials.token
    if user.new_record?
      user.password = SecureRandom.hex(20)
      user.terms_accepted_at = Time.current
    end
    user.save!
    user
  end

  def generate_password_reset_token!
    update_columns(
      reset_password_token: SecureRandom.urlsafe_base64,
      reset_password_sent_at: Time.current
    )
  end

  def password_reset_expired?
    reset_password_sent_at < 2.hours.ago
  end

  def clear_password_reset!
    update_columns(reset_password_token: nil, reset_password_sent_at: nil)
  end

  private

    def terms_must_be_accepted
      return if google_user?
      unless accept_terms == "1" || accept_terms == true
        errors.add(:accept_terms, "must be accepted to create an account")
      end
    end

    def stamp_terms_accepted_at
      return if google_user?
      if (accept_terms == "1" || accept_terms == true) && terms_accepted_at.blank?
        self.terms_accepted_at = Time.current
      end
    end
end