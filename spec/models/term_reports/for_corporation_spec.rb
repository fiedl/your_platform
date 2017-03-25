require 'spec_helper'

describe TermReports::ForCorporation do
  before do
    @term = Terms::Winter.create year: 2016

    @corporation = create :corporation_with_status_groups
    @semester_calendar = @corporation.semester_calendars.create year: 2016, term: :winter_term
    @event = @corporation.events.create name: "Winter party", start_at: "2016-12-01".to_datetime

    @new_member = create :user
    @corporation.status_groups.first.assign_user @new_member, at: "2016-12-01".to_date

    @former_member = create :user
    @former_membership = @corporation.status_groups.first.assign_user(@former_member, at: "2012-01-01".to_date)
    @former_members_group = @corporation.child_groups.create(name: "Ehemalige", type: "StatusGroup").becomes(StatusGroup)
    @former_members_group.add_flag :former_members_parent
    @former_membership.move_to @former_members_group, at: "2017-01-02".to_date

    @deceased_member = create :user
    @corporation.status_groups.first.assign_user(@deceased_member, at: "2010-01-01".to_date)
    @deceased_group = @corporation.child_groups.create(name: "Verstorbene", type: "StatusGroup").becomes(StatusGroup)
    @deceased_group.add_flag :deceased_parent
    @deceased_member.reload.mark_as_deceased at: "2016-11-19".to_date

    @term_report = @corporation.term_reports.create term_id: @term.id
    @term_report = TermReport.find @term_report.id  # In order for it to have the proper sub class.
  end

  describe "#corporation" do
    subject { @term_report.corporation }
    it { should == @corporation }
  end

  describe "#semester_calendar" do
    subject { @term_report.semester_calendar }
    it "should refer to the term's semester calendar of the corporation" do
      subject.should == @semester_calendar
      @semester_calendar.group.should == @corporation
    end
  end

  describe "#fill_info" do
    subject { @term_report.fill_info }

    it "should fill in the stats correctly" do
      subject
      @term_report.number_of_events.should == @semester_calendar.events(true).count
      @term_report.number_of_events.should == 1
      @term_report.number_of_members.should == 1
      @term_report.number_of_new_members.should == 1
      @term_report.number_of_membership_ends.should == 1
      @term_report.number_of_deaths.should == 1
    end
  end
end
