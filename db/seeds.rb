# Seed data for TideTogether.
# Run with: rails db:seed  (this clears existing records first)

require "faker"

puts "Clearing existing data..."
StudyGroupMessage.destroy_all
GroupMembership.destroy_all
StudyGroup.destroy_all
Assignment.destroy_all
User.destroy_all

# Deterministic-ish but varied data
Faker::Config.locale = "en-US"

DOMAINS = %w[u.northwestern.edu northwestern.edu].freeze

puts "Creating users..."
users = 12.times.map do |i|
  first = Faker::Name.first_name.gsub(/[^A-Za-z]/, "")
  last  = Faker::Name.last_name.gsub(/[^A-Za-z]/, "")
  handle = "#{first.downcase}.#{last.downcase}#{i}"
  domain = DOMAINS[i % DOMAINS.length]

  User.create!(
    name: "#{first} #{last}",
    email: "#{handle}@#{domain}",
    password: "password123",
    password_confirmation: "password123",
    accept_terms: "1",
    terms_accepted_at: Time.current,
    ical_url: "https://canvas.northwestern.edu/feeds/calendars/user_#{1000 + i}.ics"
  )
end

courses = [
  "COMP_SCI 394 Software Studio",
  "BIOL_SCI 215 Genetics",
  "CHEM 210 Organic Chemistry",
  "MATH 230 Multivariable Calculus",
  "ENGLISH 270 American Literature",
  "ECON 201 Microeconomics",
  "PSYCH 110 Intro Psychology"
]

assignment_titles = [
  "Reading Response", "Problem Set", "Lab Report", "Project Draft",
  "Quiz Prep", "Midterm Review", "Final Presentation", "Discussion Post",
  "Group Milestone", "Essay Outline"
]

puts "Creating assignments..."
users.each do |user|
  rand(4..8).times do
    user.assignments.create!(
      title: "#{assignment_titles.sample} - #{Faker::Lorem.word.capitalize}",
      course_name: courses.sample,
      due_date: Faker::Time.between(from: 1.day.from_now, to: 30.days.from_now).change(min: 0),
      estimated_hours: rand(1..6),
      done: [ true, false, false ].sample,
      source: "manual"
    )
  end
end

puts "Creating study groups..."
group_specs = [
  { name: "CS 394 Milestone Review", location: "Online",    style: "Balanced",  tags: %w[Rails MVP], pw: "" },
  { name: "Organic Chemistry Lab Prep", location: "In Person", style: "Talkative", tags: %w[Lab Homework], pw: "chem" },
  { name: "Quiet Calculus Sprint", location: "Online",    style: "Quiet",     tags: %w[Calculus ExamPrep], pw: "" },
  { name: "Genetics Study Circle", location: "In Person", style: "Balanced",  tags: %w[Biology Notes], pw: "" },
  { name: "Microeconomics Problem Jam", location: "Online", style: "Talkative", tags: %w[Econ Graphs], pw: "econ" }
]

groups = group_specs.each_with_index.map do |spec, i|
  creator = users[i % users.length]
  start_at = Faker::Time.between(from: 1.day.from_now, to: 7.days.from_now).change(min: 0)
  StudyGroup.create!(
    name: spec[:name],
    creator: creator,
    description: Faker::Lorem.sentence(word_count: 12),
    start_time: start_at,
    end_time: start_at + 2.hours,
    location_mode: spec[:location],
    communication_style: spec[:style],
    tags: spec[:tags],
    join_password: spec[:pw]
  )
end

puts "Adding members and messages..."
groups.each do |group|
  group.group_memberships.find_or_create_by!(user: group.creator)
  # Add 2-4 random additional members
  users.reject { |u| u == group.creator }.sample(rand(2..4)).each do |member|
    group.group_memberships.find_or_create_by!(user: member)
  end

  # A few opening messages from members
  group.members.sample(rand(2..3)).each do |member|
    group.study_group_messages.create!(
      user: member,
      content: Faker::Lorem.sentence(word_count: rand(6..14))
    )
  end
end

puts "Seeded #{User.count} users, #{Assignment.count} assignments, " \
     "#{StudyGroup.count} study groups, and #{StudyGroupMessage.count} messages."
