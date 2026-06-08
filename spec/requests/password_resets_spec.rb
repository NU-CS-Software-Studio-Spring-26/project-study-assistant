require "rails_helper"

RSpec.describe "PasswordResets", type: :request do
  let(:user)        { create(:user) }
  let(:google_user) { create(:user, :google) }

  describe "POST /password/reset" do
    it "always redirects with the generic notice (anti-enumeration)" do
      post "/password/reset", params: { email: user.email }
      expect(response).to redirect_to(new_password_reset_path)
      follow_redirect!
      expect(response.body).to include("If an account exists for that email")
    end

    it "sends an email when the account exists and is not a Google user" do
      expect {
        post "/password/reset", params: { email: user.email }
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "does NOT send email when the address is not registered" do
      expect {
        post "/password/reset", params: { email: "nobody@u.northwestern.edu" }
      }.not_to change { ActionMailer::Base.deliveries.count }
    end

    it "does NOT send email for a Google OAuth user" do
      expect {
        post "/password/reset", params: { email: google_user.email }
      }.not_to change { ActionMailer::Base.deliveries.count }
    end

    it "still redirects with the generic notice for a Google user" do
      post "/password/reset", params: { email: google_user.email }
      expect(response).to redirect_to(new_password_reset_path)
    end
  end

  describe "GET /password/reset/edit" do
    context "with a valid, unexpired token" do
      before { user.generate_password_reset_token! }

      it "renders the password entry form" do
        get "/password/reset/edit", params: { token: user.reset_password_token }
        expect(response).to have_http_status(:ok)
      end
    end

    context "with an invalid token" do
      it "redirects back to the request form with an alert" do
        get "/password/reset/edit", params: { token: "badtoken" }
        expect(response).to redirect_to(new_password_reset_path)
      end
    end

    context "with an expired token" do
      before do
        user.generate_password_reset_token!
        user.update_columns(reset_password_sent_at: 3.hours.ago)
      end

      it "redirects back to the request form with an alert" do
        get "/password/reset/edit", params: { token: user.reset_password_token }
        expect(response).to redirect_to(new_password_reset_path)
      end
    end
  end

  describe "PATCH /password/reset" do
    before { user.generate_password_reset_token! }

    context "with valid new password" do
      it "updates the password, clears the token, and logs the user in" do
        patch "/password/reset", params: {
          token:                 user.reset_password_token,
          password:              "newpassword1",
          password_confirmation: "newpassword1"
        }
        expect(response).to redirect_to(dashboard_path)
        expect(user.reload.reset_password_token).to be_nil
      end
    end

    context "with a password shorter than 8 characters" do
      it "re-renders the edit form with an error" do
        patch "/password/reset", params: {
          token:                 user.reset_password_token,
          password:              "short",
          password_confirmation: "short"
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with mismatched password confirmation" do
      it "re-renders the edit form with an error" do
        patch "/password/reset", params: {
          token:                 user.reset_password_token,
          password:              "newpassword1",
          password_confirmation: "different99"
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
