require "test_helper"

class StudyGroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @study_group = study_groups(:one)
    @user = users(:one)
    sign_in_as(@user)
  end

  test "should get index" do
    get study_groups_url
    assert_response :success
  end

  test "should get new" do
    get new_study_group_url

    assert_response :success
  end

  test "should create study group" do
    assert_difference("StudyGroup.count") do
      post study_groups_url, params: {
        study_group: {
          name: "Physics Problem Set Night",
          start_time: 2.days.from_now,
          end_time: 2.days.from_now + 2.hours,
          location_mode: "Online",
          communication_style: "Quiet",
          join_password: "",
          description: "Let's work through the problem set together and help each other out!"
        },
        custom_tags: "exam prep"
      }
    end

    assert_redirected_to study_group_url(StudyGroup.last)
    assert StudyGroup.last.members.include?(@user)
  end

  test "creator should edit and update study group" do
    get edit_study_group_url(@study_group)
    assert_response :success

    patch study_group_url(@study_group), params: {
      study_group: {
        name: "Updated Review",
        start_time: 2.days.from_now,
        end_time: 2.days.from_now + 2.hours,
        location_mode: "Online",
        communication_style: "Balanced",
        join_password: "lock123",
        description: "Updated description for the study group."
      },
      custom_tags: "calculus"
    }

    assert_redirected_to study_group_url(@study_group)
    assert_equal "Updated Review", @study_group.reload.name
  end

  test "creator should destroy study group" do
    assert_difference("StudyGroup.count", -1) do
      delete study_group_url(@study_group)
    end

    assert_redirected_to study_groups_url
  end

  test "should not create study group in the past" do
    assert_no_difference("StudyGroup.count") do
      post study_groups_url, params: {
        study_group: {
          name: "Past Session",
          start_time: 1.hour.ago,
          end_time: 30.minutes.ago,
          location_mode: "Online",
          communication_style: "Quiet",
          join_password: ""
        },
        custom_tags: ""
      }
    end

    assert_response :unprocessable_entity
    assert_match "Start time must be in the future", response.body
  end

  test "should not create study group when end time is before start time" do
    assert_no_difference("StudyGroup.count") do
      post study_groups_url, params: {
        study_group: {
          name: "Backwards Session",
          start_time: 2.days.from_now,
          end_time: 1.day.from_now,
          location_mode: "Online",
          communication_style: "Quiet",
          join_password: ""
        },
        custom_tags: ""
      }
    end

    assert_response :unprocessable_entity
    assert_match "End time must be after the start time", response.body
  end

  test "should remove expired study groups when loading index" do
    expired_group = StudyGroup.new(
      name: "Expired Session",
      study_time: 2.hours.ago,
      start_time: 2.hours.ago,
      end_time: 1.hour.ago,
      location_mode: "Online",
      communication_style: "Quiet",
      creator: @user,
      join_password: "",
      tags: []
    )
    expired_group.save(validate: false)

    assert_difference("StudyGroup.count", -1) do
      get study_groups_url
    end

    assert_response :success
    assert_not StudyGroup.exists?(expired_group.id)
  end

  test "should join study group" do
    delete logout_url
    second_user = users(:two)
    sign_in_as(second_user)

    assert_difference("GroupMembership.count") do
      post join_study_group_url(@study_group), params: { join_password: "lock123" }
    end

    assert_redirected_to study_group_url(@study_group)
    assert @study_group.members.reload.include?(second_user)
  end

  test "member should leave study group" do
    delete logout_url
    second_user = users(:two)
    sign_in_as(second_user)
    post join_study_group_url(@study_group), params: { join_password: "lock123" }

    assert_difference("GroupMembership.count", -1) do
      delete leave_study_group_url(@study_group)
    end

    assert_redirected_to study_groups_url
    assert_not @study_group.members.reload.include?(second_user)
  end

  test "creator should not leave study group" do
    assert_no_difference("GroupMembership.count") do
      delete leave_study_group_url(@study_group)
    end

    assert_redirected_to study_groups_url
    assert @study_group.members.reload.include?(@user)
  end

  test "non member should not leave study group" do
    delete logout_url
    second_user = users(:two)
    sign_in_as(second_user)

    assert_no_difference("GroupMembership.count") do
      delete leave_study_group_url(@study_group)
    end

    assert_redirected_to study_groups_url
  end

  test "should not join password protected group with wrong password" do
    delete logout_url
    second_user = users(:two)
    sign_in_as(second_user)

    assert_no_difference("GroupMembership.count") do
      post join_study_group_url(@study_group), params: { join_password: "wrong" }
    end

    assert_redirected_to study_groups_url
  end

  test "should block access to group page when not a member" do
    delete logout_url
    second_user = users(:two)
    sign_in_as(second_user)

    get study_group_url(@study_group)

    assert_redirected_to study_groups_url
  end

  test "non creator cannot update study group" do
    delete logout_url
    sign_in_as(users(:two))

    patch study_group_url(@study_group), params: {
      study_group: {
        name: "Unauthorized",
        start_time: 2.days.from_now,
        end_time: 2.days.from_now + 2.hours,
        location_mode: "Online",
        communication_style: "Balanced",
        join_password: "lock123"
      },
      custom_tags: ""
    }

    assert_redirected_to study_groups_url
    assert_not_equal "Unauthorized", @study_group.reload.name
  end

  private

  def sign_in_as(user)
    post login_url, params: { email: user.email, password: "password" }
  end
end
