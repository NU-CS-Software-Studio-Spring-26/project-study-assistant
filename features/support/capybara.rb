require "capybara/rails"

# Use rack_test (headless, no real browser) for all scenarios.
# If a scenario needs JavaScript, tag it @javascript and swap to a real driver.
Capybara.default_driver    = :rack_test
Capybara.default_max_wait_time = 2
