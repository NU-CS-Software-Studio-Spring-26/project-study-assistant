require "test_helper"

class StudyGroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @study_group = study_groups(:one)
    @user = users(:one)
    post login_url, params: { email: @user.email }
  end

  test "should get index" do
    get study_groups_url
    assert_response :success
  end

  test "should create study group" do
    assert_difference("StudyGroup.count") do
      post study_groups_url, params: {
        study_group: {
          name: "Physics Problem Set Night",
          study_time: 2.days.from_now,
          location_mode: "Online",
          communication_style: "Quiet",
          join_password: "",
          tags: [ "Focused" ]
        },
        extra_tags: "exam prep"
      }
    end

    assert_redirected_to study_groups_url
    assert StudyGroup.last.members.include?(@user)
  end

  test "should join study group" do
    delete logout_url
    second_user = users(:two)
    post login_url, params: { email: second_user.email }

    assert_difference("GroupMembership.count") do
      post join_study_group_url(@study_group), params: { join_password: "lock123" }
    end

    assert_redirected_to study_group_url(@study_group)
    assert @study_group.members.reload.include?(second_user)
  end

  test "should not join password protected group with wrong password" do
    delete logout_url
    second_user = users(:two)
    post login_url, params: { email: second_user.email }

    assert_no_difference("GroupMembership.count") do
      post join_study_group_url(@study_group), params: { join_password: "wrong" }
    end

    assert_redirected_to study_groups_url
  end

  test "should block access to group page when not a member" do
    delete logout_url
    second_user = users(:two)
    post login_url, params: { email: second_user.email }

    get study_group_url(@study_group)

    assert_redirected_to study_groups_url
  end
end