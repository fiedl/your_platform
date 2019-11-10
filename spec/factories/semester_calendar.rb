FactoryGirl.define do

  factory :semester_calendar do
    group
    term { Term.first_or_create_current }

    after :create do |semester_calendar, evaluator|
      event = semester_calendar.group.events.create name: "Happy hour"
      event.contact_people
      event.attendees
    end
  end

end