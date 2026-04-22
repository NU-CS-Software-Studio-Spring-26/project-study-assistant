class User < ApplicationRecord
	has_many :created_study_groups, class_name: "StudyGroup", foreign_key: :creator_id, inverse_of: :creator, dependent: :nullify
	has_many :group_memberships, dependent: :destroy
	has_many :study_groups, through: :group_memberships
end
