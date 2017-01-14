require 'spec_helper'

describe TermInfo do
  before do
    @term = Term.create year: 2016, term: :winter_term

    @corporation = create :corporation_with_status_groups
    @semester_calendar = @corporation.semester_calendars.create year: 2016, term: :winter_term
    @event = @corporation.child_events.create title: "Winter party", start_at: "2016-12-01".to_datetime

    @new_member = create :user
    @corporation.status_groups.first.assign_user @new_member, at: "2016-12-01".to_date

    @former_member = create :user
    @former_membership = @corporation.status_groups.first.assign_user(@former_member, at: "2012-01-01".to_date)
    @former_membership.invalidate at: "2017-01-02".to_date

    @deceased_member = create :user
    @corporation.status_groups.first.assign_user(@deceased_member, at: "2010-01-01".to_date)
    @deceased_group = @corporation.child_groups.create name: "Verstorbene"
    @deceased_group.add_flag :deceased_parent
    @deceased_member.mark_as_deceased at: "2016-11-19".to_date

    @term_info = @term.term_infos.create corporation_id: @corporation.id
  end

  describe "#corporation" do
    subject { @term_info.corporation }
    it { should == @corporation}
  end

  describe "#semester_calendar" do
    subject { @term_info.semester_calendar }
    it "should refer to the term's semester calendar of the corporation" do
      subject.should == @semester_calendar
      @semester_calendar.group.should == @corporation
    end
  end

  describe "after #fill_info" do
    before { @term_info.fill_info }

    describe "#number_of_events" do
      subject { @term_info.number_of_events }
      it { should == @semester_calendar.events(true).count }
      it { should == 1 }
    end

    describe "#number_of_members" do
      subject { @term_info.number_of_members }
      it { should == 1 }
    end

    describe "#number_of_new_members" do
      subject { @term_info.number_of_new_members }
      it { should == 1 }
    end

    describe "#number_of_membership_ends" do
      subject { @term_info.number_of_membership_ends }
      it { should == 1 }
    end

    describe "#number_of_deaths" do
      subject { @term_info.number_of_deaths }
      it { should == 1 }
    end
  end
end
