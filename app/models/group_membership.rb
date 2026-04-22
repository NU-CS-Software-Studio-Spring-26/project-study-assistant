class GroupMembership < ApplicationRecord
  belongs_to :study_group
  belongs_to :user

  validates :user_id, uniqueness: { scope: :study_group_id }
end