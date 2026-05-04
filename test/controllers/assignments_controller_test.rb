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
    @assignment.update!(source: "canvas_ical", due_time_confirmed: false)

    patch assignment_url(@assignment), params: { assignment: { course_name: @assignment.course_name, due_date: @assignment.due_date, estimated_hours: @assignment.estimated_hours, synced_to_calendar: @assignment.synced_to_calendar, title: @assignment.title } }
    assert_redirected_to assignment_url(@assignment)
    assert @assignment.reload.due_time_confirmed?
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

  test "should hide past due assignments when requested" do
    past_assignment = @user.assignments.create!(
      title: "Past Essay",
      course_name: "ENG 101",
      due_date: 1.hour.ago,
      estimated_hours: 2,
      synced_to_calendar: false
    )
    future_assignment = @user.assignments.create!(
      title: "Future Essay",
      course_name: "ENG 101",
      due_date: 1.hour.from_now,
      estimated_hours: 2,
      synced_to_calendar: false
    )

    get assignments_url
    assert_response :success
    assert_match past_assignment.title, response.body
    assert_match future_assignment.title, response.body

    get assignments_url, params: { hide_past_due: "1" }
    assert_response :success
    assert_no_match past_assignment.title, response.body
    assert_match future_assignment.title, response.body
  end

  test "should combine search with hiding past due assignments" do
    @user.assignments.create!(
      title: "Reading Past",
      course_name: "ENG 101",
      due_date: 1.hour.ago,
      estimated_hours: 1,
      synced_to_calendar: false
    )
    future_assignment = @user.assignments.create!(
      title: "Reading Future",
      course_name: "ENG 101",
      due_date: 1.hour.from_now,
      estimated_hours: 1,
      synced_to_calendar: false
    )

    get assignments_url, params: { q: "Reading", hide_past_due: "1" }

    assert_response :success
    assert_no_match "Reading Past", response.body
    assert_match future_assignment.title, response.body
    assert_no_match "Chemistry Lab", response.body
  end

  private

  def sign_in_as(user)
    post login_url, params: { email: user.email, password: "password" }
  end
end
