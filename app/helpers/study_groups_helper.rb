module StudyGroupsHelper
  def study_group_schedule(study_group)
    start_time = study_group.start_time.in_time_zone
    end_time = study_group.end_time.in_time_zone

    if start_time.to_date == end_time.to_date
      "#{start_time.strftime('%a, %b %-d')} from #{start_time.strftime('%-I:%M %p')} - #{end_time.strftime('%-I:%M %p')}"
    else
      safe_join([
        "#{start_time.strftime('%a, %b %-d at %-I:%M %p')} -",
        tag.br,
        end_time.strftime('%a, %b %-d at %-I:%M %p')
      ])
    end
  end
end