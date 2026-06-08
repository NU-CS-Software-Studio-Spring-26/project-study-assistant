FactoryBot.define do
  factory :study_group do
    association :creator, factory: :user
    sequence(:name)     { |n| "Study Group #{n}" }
    start_time          { 1.day.from_now }
    end_time            { 2.days.from_now }
    location_mode       { "Online" }
    communication_style { "Balanced" }
  end
end
