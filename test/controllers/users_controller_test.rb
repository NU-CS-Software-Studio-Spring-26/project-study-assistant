require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
    sign_in_as(@user)
  end

  test "should get new" do
    delete logout_url

    get new_user_url

    assert_response :success
  end

  test "should create user" do
    assert_difference("User.count") do
      post users_url, params: { user: { email: "new@example.com", name: "New Student", password: "password", password_confirmation: "password" } }
    end

    assert_redirected_to dashboard_url
  end

  test "should show user" do
    get user_url(@user)
    assert_response :success
  end

  test "should get edit" do
    get edit_user_url(@user)
    assert_response :success
  end

  test "should update user" do
    patch user_url(@user), params: { user: { email: @user.email, name: "Updated Alex", ical_url: @user.ical_url } }
    assert_redirected_to user_url(@user)
  end

  test "should sync own canvas calendar" do
    result = IcalSyncService::Result.new(imported: 2, updated: 1, skipped_events: 3, failed: 0)
    service = SyncServiceStub.new(result)

    original_new = IcalSyncService.method(:new)
    begin
      IcalSyncService.define_singleton_method(:new) { |_| service }
      post sync_ical_user_url(@user)
    ensure
      IcalSyncService.define_singleton_method(:new, original_new)
    end

    assert service.synced?
    assert_redirected_to assignments_url
  end

  test "should not sync another user's canvas calendar" do
    post sync_ical_user_url(@other_user)

    assert_redirected_to dashboard_url
  end

  test "should destroy user" do
    assert_difference("User.count", -1) do
      delete user_url(@user)
    end

    assert_redirected_to root_url
  end

  test "should not show another user" do
    get user_url(@other_user)

    assert_redirected_to dashboard_url
  end

  test "should not update another user" do
    patch user_url(@other_user), params: { user: { name: "Bad Update" } }

    assert_redirected_to dashboard_url
    assert_not_equal "Bad Update", @other_user.reload.name
  end

  private

  def sign_in_as(user)
    post login_url, params: { email: user.email, password: "password" }
  end

  class SyncServiceStub
    def initialize(result)
      @result = result
      @synced = false
    end

    def sync
      @synced = true
      @result
    end

    def synced?
      @synced
    end
  end
end
