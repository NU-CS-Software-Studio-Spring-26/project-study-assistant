# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


# require 'faker'

# # Clear existing data
# Assignment.destroy_all
# User.destroy_all

# # Create 10 users
# 10.times do
#   User.create!(
#     name: Faker::Name.name,
#     email: Faker::Internet.email,
#     canvas_token: SecureRandom.hex(16),
#     calendar_preference: ["google", "apple"].sample
#   )
# end

# # Create 30 assignments
# course_names = ["CS 394", "CS 340", "CS 335", "ECON 201", "MATH 230"]
# assignment_titles = ["Homework", "Project", "Lab", "Quiz", "Essay"]

# 30.times do |i|
#   Assignment.create!(
#     title: "#{assignment_titles.sample} #{i + 1}",
#     course_name: course_names.sample,
#     due_date: Faker::Time.forward(days: 60),
#     estimated_hours: rand(1..10),
#     synced_to_calendar: [true, false].sample
#   )
# end

# puts "Seeded #{User.count} users and #{Assignment.count} assignments"

Assignment.destroy_all
User.destroy_all

puts "Database cleared"