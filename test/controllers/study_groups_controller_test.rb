require "test_helper"

class StudyGroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @study_group = study_groups(:one)
    @user = users(:one)
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
          creator_id: @user.id,
          tags: [ "Focused" ]
        },
        extra_tags: "exam prep"
      }
    end

    assert_redirected_to study_groups_url
    assert StudyGroup.last.members.include?(@user)
  end

  test "should join study group" do
    second_user = users(:two)

    assert_difference("GroupMembership.count") do
      post join_study_group_url(@study_group), params: { user_id: second_user.id }
    end

    assert_redirected_to study_groups_url
    assert @study_group.members.reload.include?(second_user)
  end
end