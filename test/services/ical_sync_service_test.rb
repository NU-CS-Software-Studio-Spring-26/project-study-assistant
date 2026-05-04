require "test_helper"
require "stringio"

class IcalSyncServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "imports assignment entries and skips calendar events" do
    result = IcalSyncService.new(@user, calendar_io: StringIO.new(sample_ical)).sync

    assert_equal 2, result.imported
    assert_equal 0, result.updated
    assert_equal 1, result.skipped_events
    assert_equal 0, result.failed

    assert @user.assignments.exists?(canvas_id: "event-assignment-date-only")
    assert_not @user.assignments.exists?(canvas_id: "event-calendar-event-lecture")
  end

  test "marks imported due times as unconfirmed" do
    IcalSyncService.new(@user, calendar_io: StringIO.new(sample_ical)).sync

    date_only_assignment = @user.assignments.find_by!(canvas_id: "event-assignment-date-only")
    timed_assignment = @user.assignments.find_by!(canvas_id: "event-assignment-timed")

    assert_equal "canvas_ical", date_only_assignment.source
    assert_not date_only_assignment.due_time_confirmed?
    assert_equal 23, date_only_assignment.due_date.hour
    assert_equal 59, date_only_assignment.due_date.min
    assert_not timed_assignment.due_time_confirmed?
  end

  test "updates existing imported assignments without duplicates" do
    IcalSyncService.new(@user, calendar_io: StringIO.new(sample_ical)).sync

    assert_no_difference("Assignment.count") do
      result = IcalSyncService.new(@user, calendar_io: StringIO.new(updated_sample_ical)).sync
      assert_equal 0, result.imported
      assert_equal 2, result.updated
    end

    assert_equal "Updated Homework [CS 397]", @user.assignments.find_by!(canvas_id: "event-assignment-date-only").title
  end

  test "returns a failed result for malformed feeds" do
    result = IcalSyncService.new(@user, calendar_io: StringIO.new("not calendar data")).sync

    assert_equal 1, result.failed
  end

  private

  def sample_ical
    <<~ICAL
      BEGIN:VCALENDAR
      VERSION:2.0
      BEGIN:VEVENT
      UID:event-assignment-date-only
      DTSTART;VALUE=DATE:20260505
      SUMMARY:Homework 1 [CS 397]
      URL;VALUE=URI:https://canvas.example.com/assignments/1
      END:VEVENT
      BEGIN:VEVENT
      UID:event-calendar-event-lecture
      DTSTART:20260505T160000Z
      DTEND:20260505T172000Z
      SUMMARY:Lecture [CS 397]
      URL;VALUE=URI:https://canvas.example.com/calendar
      END:VEVENT
      BEGIN:VEVENT
      UID:event-assignment-timed
      DTSTART:20260506T220000Z
      DTEND:20260506T220000Z
      SUMMARY:Quiz [CS 397]
      URL;VALUE=URI:https://canvas.example.com/assignments/2
      END:VEVENT
      END:VCALENDAR
    ICAL
  end

  def updated_sample_ical
    sample_ical.sub("Homework 1 [CS 397]", "Updated Homework [CS 397]")
  end
end
