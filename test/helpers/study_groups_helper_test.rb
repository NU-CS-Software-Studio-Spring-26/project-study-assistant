require "test_helper"

class StudyGroupsHelperTest < ActionView::TestCase
  include StudyGroupsHelper

  test "formats same-day schedules with a long dash and shortened times" do
    start_time = Time.zone.local(2026, 5, 27, 14, 0)
    end_time = Time.zone.local(2026, 5, 27, 16, 0)

    group = Struct.new(:start_time, :end_time).new(start_time, end_time)

    assert_equal "Wed, May 27 • 2 – 4 PM", study_group_schedule(group)
  end

  test "formats same-day schedules with different meridiems" do
    start_time = Time.zone.local(2026, 5, 27, 11, 30)
    end_time = Time.zone.local(2026, 5, 27, 13, 0)

    group = Struct.new(:start_time, :end_time).new(start_time, end_time)

    assert_equal "Wed, May 27 • 11:30 AM – 1 PM", study_group_schedule(group)
  end

  test "formats multi-day schedules on separate rows" do
    start_time = Time.zone.local(2026, 5, 27, 14, 0)
    end_time = Time.zone.local(2026, 5, 28, 16, 0)

    group = Struct.new(:start_time, :end_time).new(start_time, end_time)

    assert_equal(
      "<span class=\"d-block\">Wed, May 27 at 2 PM –</span><span class=\"d-block\">Thu, May 28 at 4 PM</span>",
      study_group_schedule(group).to_s
    )
  end

  test "censors bad words with hash characters" do
    assert_equal "This is #### and #####.", censor_chat_content("This is shit and bitch.")
  end

  test "censors bad words case-insensitively" do
    assert_equal "#######", censor_chat_content("FuCkEr")
  end
end