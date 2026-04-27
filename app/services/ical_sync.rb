require 'open-uri'
require 'icalendar'

class IcalSyncService
  def initialize(user)
    @user = user
  end

  def sync
    return if @user.ical_url.blank?

    cal_file = URI.open(@user.ical_url)
    calendars = Icalendar::Calendar.parse(cal_file)
    calendar = calendars.first

    calendar.events.each do |event|
      Assignment.find_or_create_by(canvas_id: event.uid.to_s) do |a|
        a.title = event.summary.to_s
        a.course_name = extract_course(event.summary.to_s)
        a.due_date = event.dtend&.to_time || event.dtstart&.to_time
        a.user_id = @user.id
        a.synced_to_calendar = false
        a.estimated_hours = 1
      end
    end
  end

  private

  def extract_course(summary)
    summary.match(/\[(.+?)\]/)&.captures&.first || "Unknown Course"
  end
end