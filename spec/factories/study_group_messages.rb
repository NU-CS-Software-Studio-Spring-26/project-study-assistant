FactoryBot.define do
  factory :study_group_message do
    association :study_group
    association :user
    content { "Hello, study group!" }

    # user_must_be_group_member validation fires at save time.
    # When using the :create strategy, both associations are persisted before
    # after(:build) runs, so we can safely create the membership here.
    after(:build) do |message|
      if message.study_group&.persisted? && message.user&.persisted?
        GroupMembership.find_or_create_by!(
          study_group: message.study_group,
          user: message.user
        )
      end
    end
  end
end
