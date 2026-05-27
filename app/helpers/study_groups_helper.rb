module StudyGroupsHelper
  def study_group_schedule(study_group)
    start_time = study_group.start_time.in_time_zone
    end_time = study_group.end_time.in_time_zone

    if start_time.to_date == end_time.to_date
      "#{study_group_date_label(start_time)} • #{study_group_time_label(start_time, meridiem: false)} #{study_group_time_separator(start_time, end_time)} #{study_group_time_label(end_time, meridiem: false)} #{end_time.strftime('%p')}"
    else
      safe_join([
        content_tag(:span, "#{study_group_date_label(start_time)} at #{study_group_time_label(start_time)} –", class: "d-block"),
        content_tag(:span, "#{study_group_date_label(end_time)} at #{study_group_time_label(end_time)}", class: "d-block")
      ])
    end
  end

  def study_group_date_label(time)
    time.strftime('%a, %b %-d')
  end

  def study_group_time_label(time, meridiem: true)
    label = time.strftime('%-I')
    label += time.min.zero? ? '' : time.strftime(':%M')
    meridiem ? "#{label} #{time.strftime('%p')}" : label
  end

  def study_group_time_separator(start_time, end_time)
    start_time.strftime('%p') == end_time.strftime('%p') ? '–' : "#{start_time.strftime('%p')} –"
  end
end