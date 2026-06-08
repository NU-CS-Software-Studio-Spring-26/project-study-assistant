# ──────────────────────────────────────────────────────────────────────────────
# Navigation
# ──────────────────────────────────────────────────────────────────────────────

Given("I am on the sign up page") do
  visit new_user_path
end

Given("I am on the login page") do
  visit login_path
end

Given("I am on the new study group page") do
  visit new_study_group_path
end

# ──────────────────────────────────────────────────────────────────────────────
# Auth setup helpers
# ──────────────────────────────────────────────────────────────────────────────

Given("a user account exists with email {string} and password {string}") do |email, password|
  create(:user, email: email, password: password, password_confirmation: password)
end

Given("I am logged in as a student") do
  @current_user = create(:user)
  visit login_path
  # The login form uses form.label (proper for= association), so fill_in by label works.
  fill_in "Email",    with: @current_user.email
  fill_in "Password", with: "password123"
  click_button "Sign In"
end

# ──────────────────────────────────────────────────────────────────────────────
# Sign-up form
#
# NOTE: The users/_form.html.erb uses plain <label> tags WITHOUT a for= attribute,
# so Capybara cannot locate fields by label text. We locate by name attribute instead
# (e.g. fill_in "user[name]"). Verify against your actual rendered HTML if these fail.
# ──────────────────────────────────────────────────────────────────────────────

When("I fill in my registration details") do
  fill_in "user[name]",                  with: "Cucumber Student"
  fill_in "user[email]",                 with: "cucumbertest@u.northwestern.edu"
  fill_in "user[password]",              with: "password123"
  fill_in "user[password_confirmation]", with: "password123"
end

When("I accept the terms of service") do
  # form.check_box :accept_terms generates id="user_accept_terms"
  check "user_accept_terms"
end

When("I do not accept the terms of service") do
  # Intentionally leave the checkbox unchecked.
  # rack_test bypasses HTML required= so the form submits with accept_terms="0"
  # (the hidden field value), triggering the server-side validation.
end

# ──────────────────────────────────────────────────────────────────────────────
# Study group form
#
# The study group form uses form.label helpers (proper for= associations),
# so fill_in by label text works here.
# ──────────────────────────────────────────────────────────────────────────────

When("I fill in the study group form with valid details") do
  future_start = 1.day.from_now.strftime("%Y-%m-%dT%H:%M")
  future_end   = 2.days.from_now.strftime("%Y-%m-%dT%H:%M")

  fill_in "Group Name",  with: "CS 101 Study Session"
  fill_in "Start Time",  with: future_start
  fill_in "End Time",    with: future_end
  # Labels: "Online Or In Person" → select id="study_group_location_mode"
  #         "Group Style"         → select id="study_group_communication_style"
  select "Online",   from: "Online Or In Person"
  select "Balanced", from: "Group Style"
end

When("I fill in the study group form with profanity in the name") do
  future_start = 1.day.from_now.strftime("%Y-%m-%dT%H:%M")
  future_end   = 2.days.from_now.strftime("%Y-%m-%dT%H:%M")

  fill_in "Group Name",  with: "shit study group"
  fill_in "Start Time",  with: future_start
  fill_in "End Time",    with: future_end
  select "Online",   from: "Online Or In Person"
  select "Balanced", from: "Group Style"
end

# ──────────────────────────────────────────────────────────────────────────────
# Generic interactions
# ──────────────────────────────────────────────────────────────────────────────

When("I fill in {string} with {string}") do |field, value|
  fill_in field, with: value
end

When("I click the {string} button") do |button|
  click_button button
end

# ──────────────────────────────────────────────────────────────────────────────
# Assertions
# ──────────────────────────────────────────────────────────────────────────────

Then("I should be on the dashboard") do
  # UsersController#create redirects to dashboard_path (/dashboard).
  expect(page).to have_current_path("/dashboard")
end

Then("I should be on the assignments page") do
  # SessionsController#create redirects to assignments_path (/assignments).
  expect(page).to have_current_path("/assignments")
end

Then("I should see {string}") do |text|
  expect(page).to have_content(text)
end
