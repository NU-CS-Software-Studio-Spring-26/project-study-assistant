require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let(:user) { create(:user) }

  describe "POST /login" do
    context "with correct credentials" do
      it "logs the user in and redirects to assignments" do
        post "/login", params: { email: user.email, password: "password123" }
        expect(response).to redirect_to(assignments_path)
      end
    end

    context "with an incorrect password" do
      it "re-renders the login form with an error" do
        post "/login", params: { email: user.email, password: "wrongpassword" }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Invalid email or password")
      end
    end

    context "with an email that does not exist" do
      it "re-renders the login form with an error" do
        post "/login", params: { email: "nobody@u.northwestern.edu", password: "password123" }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Invalid email or password")
      end
    end
  end

  describe "DELETE /logout" do
    it "clears the session and redirects to root" do
      post "/login", params: { email: user.email, password: "password123" }
      delete "/logout"
      expect(response).to redirect_to(root_path)
    end
  end
end
