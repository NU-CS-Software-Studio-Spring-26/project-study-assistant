FactoryBot.define do
  factory :assignment do
    association :user
    sequence(:title) { |n| "Assignment #{n}" }
    course_name      { "CS 101" }
    due_date         { 1.week.from_now }
    source           { "manual" }
  end
end
