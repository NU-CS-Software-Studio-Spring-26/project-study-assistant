require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get login form" do
    get login_url
    assert_response :success
  end

  test "should login with valid password" do
    post login_url, params: { email: users(:one).email, password: "password" }

    assert_redirected_to assignments_url
    assert_equal users(:one).id, session[:user_id]
  end

  test "should reject invalid login without leaking account existence" do
    post login_url, params: { email: users(:one).email, password: "wrong" }

    assert_response :unprocessable_entity
    assert_match "Invalid email or password.", response.body
  end

  test "should logout" do
    post login_url, params: { email: users(:one).email, password: "password" }

    delete logout_url

    assert_redirected_to root_url
    assert_nil session[:user_id]
  end
end
