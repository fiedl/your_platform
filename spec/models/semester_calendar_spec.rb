require 'spec_helper'

describe SemesterCalendar do
  before do
    @corporation = create :corporation
    @term = Term.by_year_and_type Time.zone.now.year, "Terms::Summer"
    @semester_calendar = @corporation.semester_calendars.create term_id: @term.id
    @event = Event.create name: "BBQ", start_at: Time.zone.now.change(month: 8)
    @event_in_another_term = Event.create name: "Christmas Party", start_at: Time.zone.now.change(month: 12)
    @corporation << @event
    @corporation << @event_in_another_term
    @semester_calendar.reload.events
  end

  describe "#events" do
    subject { @semester_calendar.events }
    it "should include the events of the given term and year" do
      subject.should include @event
    end
    it "should not include the events of other terms" do
      subject.should_not include @event_in_another_term
    end
    describe "for corporations with subgroups" do
      before do
        @subgroup = @corporation.child_groups.create name: "Subgroup"
        wait_for_cache
        @sub_event = @subgroup.events.create name: "Clean-up after BBQ", start_at: @event.start_at + 6.hours
        @semester_calendar.reload.events.reload
      end
      it "should include the events of subgroups" do
        subject.should include @sub_event
      end
    end
  end

  describe ".by_corporation_and_term" do
    subject { SemesterCalendar.by_corporation_and_term(@corporation, @term) }
    describe "for an existing summer term and an existing semester calendar" do
      before { @term = Term.by_year_and_type(Time.zone.now.year, "Terms::Summer") }
      it "should return the existing semester calendar" do
        subject.should == @semester_calendar
      end
    end
    describe "for a non-existing winter term and a non-existing semester calendar" do
      before { @term = Term.by_year_and_type(Time.zone.now.year, "Terms::Winter") }
      its(:id) { should be_present }
      its(:term) { should be_kind_of Terms::Winter }
      its(:year) { should == Time.zone.now.year }
    end
  end

end
