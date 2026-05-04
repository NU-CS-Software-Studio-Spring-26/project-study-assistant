require "open-uri"
require "icalendar"

class IcalSyncService
  Result = Struct.new(:imported, :updated, :skipped_events, :failed, keyword_init: true) do
    def success?
      failed.zero?
    end
  end

  ASSIGNMENT_UID_PREFIX = "event-assignment-"
  CALENDAR_EVENT_UID_PREFIX = "event-calendar-event-"

  def initialize(user, calendar_io: nil)
    @user = user
    @calendar_io = calendar_io
  end

  def sync
    result = Result.new(imported: 0, updated: 0, skipped_events: 0, failed: 0)
    return result if @user.ical_url.blank? && @calendar_io.blank?

    calendars = Icalendar::Calendar.parse(calendar_source.read)
    events = calendars.flat_map(&:events)
    return Result.new(imported: 0, updated: 0, skipped_events: 0, failed: 1) if calendars.empty? || events.empty?

    events.each do |event|
      sync_event(event, result)
    end

    result
  rescue Icalendar::Parser::ParseError, OpenURI::HTTPError, SocketError, Socket::ResolutionError
    Rails.logger.info("Skipped iCal sync for user #{@user.id}: calendar URL was not reachable")
    Result.new(imported: 0, updated: 0, skipped_events: 0, failed: 1)
  end

  private

  def calendar_source
    @calendar_io || URI.open(@user.ical_url)
  end

  def sync_event(event, result)
    uid = event.uid.to_s
    if uid.start_with?(CALENDAR_EVENT_UID_PREFIX)
      result.skipped_events += 1
      return
    end
    return unless uid.start_with?(ASSIGNMENT_UID_PREFIX)

    assignment = @user.assignments.find_or_initialize_by(canvas_id: uid)
    assignment.assign_attributes(
      title: event.summary.to_s,
      course_name: extract_course(event.summary.to_s),
      due_date: due_date_for(event),
      estimated_hours: assignment.estimated_hours || 1,
      synced_to_calendar: true,
      source: "canvas_ical",
      due_time_confirmed: false
    )

    assignment.new_record? ? result.imported += 1 : result.updated += 1
    assignment.save!
  rescue ActiveRecord::RecordInvalid
    result.failed += 1
  end

  def due_date_for(event)
    due_value = event.dtend || event.dtstart
    return if due_value.blank?

    if due_value.is_a?(Icalendar::Values::Date)
      due_value.to_date.in_time_zone.change(hour: 23, min: 59)
    else
      due_value.to_time.in_time_zone
    end
  end

  def extract_course(summary)
    summary.match(/\[(.+?)\]/)&.captures&.first || "Unknown Course"
  end
end
