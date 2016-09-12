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
    new_event = semester_calendar.group.child_events.new
    uniq_id = new_event.object_id
    fields = form.fields_for :events, new_event, child_index: uniq_id do |builder|
      render partial: "semester_calendars/event_edit_row", locals: {form: builder}
    end
    link_to title, '#', class: "add_semester_calendar_event #{options[:class]}", data: {id: uniq_id, fields: fields.gsub("\n", "")}
  end

end