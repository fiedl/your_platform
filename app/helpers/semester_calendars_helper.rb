module SemesterCalendarsHelper

  def semester_calendar_terms_hash
    # For select inputs
    SemesterCalendar.terms.keys.map { |term| [t(term), term] }
  end

  def semester_calendar_check_box_columns
    [:publish_on_local_website, :publish_on_global_website]
  end

  def link_to_add_semester_calendar_event(title, options = {})
    # http://railscasts.com/episodes/196-nested-model-form-revised
    form = options[:form] || raise('no form given')
    semester_calendar = form.object
    new_event = semester_calendar.group.events.new
    new_event.contact_person_id = semester_calendar_default_contact_person(semester_calendar).try(:id)
    uniq_id = new_event.object_id
    fields = form.fields_for :events, new_event, child_index: uniq_id do |builder|
      render partial: "semester_calendars/event_edit_row", locals: {form: builder}
    end
    link_to title, '#', class: "add_semester_calendar_event #{options[:class]}", data: {id: uniq_id, fields: fields.gsub("\n", "")}
  end

  def format_event_datetime(datetime)
    datetime.strftime("%a, %d.%m %H:%M")
      .gsub(":00", "h st").gsub(":15", "h ct")
      .gsub("Mon", "Mo").gsub("Tue", "Di").gsub("Wed", "Mi").gsub("Thu", "Do")
      .gsub("Fri", "Fr").gsub("Sat", "Sa").gsub("Sun", "So")
  end

  def semester_calendar_default_contact_person(semester_calendar)
    current_user
  end

end