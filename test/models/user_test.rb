require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "requires profile and password fields" do
    user = User.new(email: "student@example.com", password: "password", password_confirmation: "password")

    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "normalizes email and authenticates password" do
    user = User.create!(
      name: "Taylor Student",
      email: "  Taylor@Example.COM ",
      password: "password",
      password_confirmation: "password"
    )

    assert_equal "taylor@example.com", user.email
    assert user.authenticate("password")
    assert_not user.authenticate("wrong-password")
  end
end
