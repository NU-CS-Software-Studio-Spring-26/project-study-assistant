FactoryBot.define do
  factory :user do
    sequence(:name)  { |n| "Test User #{n}" }
    sequence(:email) { |n| "user#{n}@u.northwestern.edu" }
    password              { "password123" }
    password_confirmation { "password123" }
    accept_terms          { "1" }

    trait :google do
      sequence(:email) { |n| "googleuser#{n}@u.northwestern.edu" }
      provider         { "google_oauth2" }
      sequence(:uid)   { |n| "google_uid_#{n}" }
      terms_accepted_at { Time.current }
      # accept_terms validation is skipped for google_user? — no need to set it
    end
  end
end
