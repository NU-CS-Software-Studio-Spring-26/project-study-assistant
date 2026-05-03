require "test_helper"

class AssignmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @assignment = assignments(:one)
    @other_assignment = assignments(:two)
    @user = users(:one)
    sign_in_as(@user)
  end

  test "should get index" do
    get assignments_url
    assert_response :success
  end

  test "should get new" do
    get new_assignment_url
    assert_response :success
  end

  test "should create assignment" do
    assert_difference("Assignment.count") do
      post assignments_url, params: { assignment: { course_name: "CS 397", due_date: 1.week.from_now, estimated_hours: 4, synced_to_calendar: false, title: "Milestone Polish" } }
    end

    assert_redirected_to assignment_url(Assignment.last)
    assert_equal @user, Assignment.last.user
  end

  test "should show assignment" do
    get assignment_url(@assignment)
    assert_response :success
  end

  test "should get edit" do
    get edit_assignment_url(@assignment)
    assert_response :success
  end

  test "should update assignment" do
    patch assignment_url(@assignment), params: { assignment: { course_name: @assignment.course_name, due_date: @assignment.due_date, estimated_hours: @assignment.estimated_hours, synced_to_calendar: @assignment.synced_to_calendar, title: @assignment.title } }
    assert_redirected_to assignment_url(@assignment)
  end

  test "should destroy assignment" do
    assert_difference("Assignment.count", -1) do
      delete assignment_url(@assignment)
    end

    assert_redirected_to assignments_url
  end

  test "should require login" do
    delete logout_url

    get assignments_url

    assert_redirected_to login_url
  end

  test "should not access another user's assignment" do
    get assignment_url(@other_assignment)

    assert_redirected_to root_url
  end

  test "should search own assignments" do
    get assignments_url, params: { q: "Reading" }

    assert_response :success
    assert_match "Reading Response", response.body
    assert_no_match "Chemistry Lab", response.body
  end

  private

  def sign_in_as(user)
    post login_url, params: { email: user.email, password: "password" }
  end
end
