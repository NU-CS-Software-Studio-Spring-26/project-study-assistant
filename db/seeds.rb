StudyGroupMessage.destroy_all
GroupMembership.destroy_all
StudyGroup.destroy_all
Assignment.destroy_all
User.destroy_all

users = [
  [ "Alex Carter", "alex@example.com" ],
  [ "Sam Rivera", "sam@example.com" ],
  [ "Jordan Lee", "jordan@example.com" ],
  [ "Taylor Morgan", "taylor@example.com" ]
].map do |name, email|
  User.create!(
    name: name,
    email: email,
    password: "password",
    password_confirmation: "password",
    ical_url: "https://calendar.example.com/#{email.split("@").first}.ics"
  )
end

courses = [ "CS 397", "BIO 101", "CHEM 110", "MATH 230", "ENG 201" ]
titles = [ "Reading Response", "Problem Set", "Lab Report", "Project Draft", "Quiz Prep" ]

24.times do |index|
  owner = users[index % users.length]
  owner.assignments.create!(
    title: "#{titles[index % titles.length]} #{index + 1}",
    course_name: courses[index % courses.length],
    due_date: (index + 1).days.from_now.change(hour: 23, min: 59),
    estimated_hours: (index % 6) + 1,
    synced_to_calendar: index.even?
  )
end

groups = [
  {
    name: "CS 397 Milestone Review",
    creator: users.first,
    start_time: 2.days.from_now.change(hour: 18, min: 0),
    end_time: 2.days.from_now.change(hour: 20, min: 0),
    location_mode: "Online",
    communication_style: "Balanced",
    tags: [ "MVP", "Rails" ],
    join_password: ""
  },
  {
    name: "Chemistry Lab Prep",
    creator: users.second,
    start_time: 3.days.from_now.change(hour: 15, min: 0),
    end_time: 3.days.from_now.change(hour: 16, min: 30),
    location_mode: "In Person",
    communication_style: "Talkative",
    tags: [ "Lab", "Homework" ],
    join_password: "chem"
  },
  {
    name: "Quiet Calculus Sprint",
    creator: users.third,
    start_time: 4.days.from_now.change(hour: 10, min: 0),
    end_time: 4.days.from_now.change(hour: 12, min: 0),
    location_mode: "Online",
    communication_style: "Quiet",
    tags: [ "Calculus", "Exam Prep" ],
    join_password: ""
  }
].map { |attributes| StudyGroup.create!(attributes) }

groups.each do |group|
  group.group_memberships.find_or_create_by!(user: group.creator)
  group.group_memberships.find_or_create_by!(user: users.sample)
  group.study_group_messages.create!(user: group.creator, content: "I started this group for our next deadline.")
end

puts "Seeded #{User.count} users, #{Assignment.count} assignments, #{StudyGroup.count} study groups, and #{StudyGroupMessage.count} messages."
