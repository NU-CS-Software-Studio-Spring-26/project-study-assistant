class StudyGroupMessage < ApplicationRecord
  belongs_to :study_group
  belongs_to :user

  validates :content, presence: true, length: { maximum: 1_000 }
  validate :user_must_be_group_member

  after_create_commit :broadcast_message

  private

  def user_must_be_group_member
    return if study_group.blank? || user.blank?
    return if study_group.members.exists?(id: user.id)

    errors.add(:user, "must join the group before posting")
  end

  def broadcast_message
    broadcast_append_to(
      [study_group, :messages],
      target: "study_group_#{study_group.id}_messages",
      partial: "study_group_messages/study_group_message",
      locals: { message: self }
    )
  end
end
