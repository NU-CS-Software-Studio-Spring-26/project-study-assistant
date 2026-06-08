require "rails_helper"

RSpec.describe User, type: :model do
  describe "valid user" do
    it "is valid with proper attributes" do
      expect(build(:user)).to be_valid
    end
  end

  describe "email validations" do
    it "is invalid with a non-Northwestern email" do
      user = build(:user, email: "student@gmail.com")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it "is invalid without an email" do
      user = build(:user, email: "")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it "is valid with a @northwestern.edu email" do
      user = build(:user, email: "prof@northwestern.edu")
      expect(user).to be_valid
    end
  end

  describe "password validations" do
    it "is invalid on create with a password under 8 characters" do
      user = build(:user, password: "short", password_confirmation: "short")
      expect(user).not_to be_valid
      expect(user.errors[:password]).to be_present
    end
  end

  describe "terms acceptance" do
    it "is invalid on create without accept_terms" do
      user = build(:user, accept_terms: nil)
      expect(user).not_to be_valid
      expect(user.errors[:accept_terms]).to be_present
    end

    it "is invalid on create when accept_terms is '0' (unchecked checkbox)" do
      user = build(:user, accept_terms: "0")
      expect(user).not_to be_valid
      expect(user.errors[:accept_terms]).to be_present
    end

    it "skips the terms validation for Google users" do
      user = build(:user, :google, accept_terms: nil)
      expect(user).to be_valid
    end
  end

  describe "password reset helpers" do
    let(:user) { create(:user) }

    it "generate_password_reset_token! sets the token and timestamp" do
      user.generate_password_reset_token!
      expect(user.reload.reset_password_token).to be_present
      expect(user.reset_password_sent_at).to be_within(5.seconds).of(Time.current)
    end

    it "password_reset_expired? returns true after 2 hours" do
      user.update_columns(reset_password_sent_at: 3.hours.ago)
      expect(user.password_reset_expired?).to be true
    end

    it "password_reset_expired? returns false within 2 hours" do
      user.update_columns(reset_password_sent_at: 1.hour.ago)
      expect(user.password_reset_expired?).to be false
    end

    it "clear_password_reset! nils both columns" do
      user.generate_password_reset_token!
      user.clear_password_reset!
      expect(user.reload.reset_password_token).to be_nil
      expect(user.reset_password_sent_at).to be_nil
    end
  end
end
