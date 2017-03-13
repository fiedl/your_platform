require 'spec_helper'

describe Event do

  before do
    @group = create( :group )
    @another_group = create( :group )
    @event = create( :event )
    @event.group = @group; @event.save
    @event.reload # otherwise some associations are apparently missing
  end

  # Groups
  # ==========================================================================================

  describe "#group" do
    subject { @event.group }
    it "should return the associated group" do
      subject.should == @group
    end
  end

  describe "#group=" do
    subject { @event.group = @another_group }
    it "should associate the new group and remove previous group associations" do
      @event.group.should == @group
      subject
      @event.group.should == @another_group
    end
  end


  # Contact People and Attendees
  # ==========================================================================================

  describe "#contact_people" do
    subject { @event.contact_people }
    before { @user = create :user }
    specify "it should return users in the contact people group" do
      @event.contact_people.should_not include @user
      @event.contact_people_group.assign_user @user; time_travel 2.seconds
      @event.contact_people.should include @user
    end
    specify "it should not return users that left through an un-assign" do
      @event.contact_people.should_not include @user
      @event.contact_people_group.assign_user @user; time_travel 2.seconds
      @event.contact_people.should include @user
      @event.contact_people_group.unassign_user @user; time_travel 2.seconds
      @event.contact_people.should_not include @user
    end
  end

  describe "#attendees" do
    subject { @event.attendees }
    before { @user = create :user }
    specify "it should return joined users" do
      @event.attendees.should_not include @user
      @user.join @event; time_travel 2.seconds
      @event.attendees.should include @user
    end
    specify "it should not return users that left through an un-assign" do
      @event.attendees.should_not include @user
      @user.join @event; time_travel 2.seconds
      @event.attendees.should include @user
      @event.attendees_group.unassign_user @user; time_travel 2.seconds
      @event.attendees.should_not include @user
    end
    specify "multiple joins should not create several attendees groups (bug fix)" do
      @user.join @event
      @other_user = create :user; @other_user.join @event
      subject.should include @user, @other_user
      @event.child_groups.find_all_by_flag(:attendees).count.should == 1
    end
  end


  # Scopes
  # ==========================================================================================

  describe ".upcoming" do
    before do
      @upcoming_event = create(:event, start_at: 5.hours.from_now, group_id: @group.id)
      @recent_event = create(:event, start_at: 2.days.ago, end_at: 2.days.ago + 2.hours, group_id: @group.id)
      @recent_event_today = create(:event, start_at: Date.today.to_datetime.change(hour: 0, min: 5))
      @unrelated_event = create( :event, start_at: 5.hours.from_now )
    end
    subject { Event.upcoming }
    it "should return events starting in the future" do
      subject.should include @upcoming_event
    end
    it "should not return events having started some days ago (in the past)" do
      subject.should_not include @recent_event
    end
    it "should return events that have started on the same day, i.e. are currently in progress" do
      subject.should include @recent_event_today
    end
    describe "chained with .find_all_by_group" do
      subject { Event.find_all_by_group( @group ).upcoming }
      it "should commute with find_all_by_group" do
        Event.find_all_by_group(@group).upcoming.to_a.should ==
          Event.upcoming.find_all_by_group(@group).to_a
      end
      it "should return associated events starting in the future" do
        subject.should include @upcoming_event
      end
      it "should not return associated events starting in the past" do
        subject.should_not include @recent_event
      end
      it "should not return un-associated events" do
        subject.should_not include @unrelated_event
      end
    end
  end

  describe "Group#direct_events" do
    # group_a
    #   |----- event_0
    #   |----- group_b
    #   |        |------ event_1
    #   |        |------ user
    #   |
    #   |----- group_c
    #            |------ event_2
    before do
      @group_a = create( :group )
      @event_0 = @group_a.events.create
      @group_b = @group_a.child_groups.create
      @event_1 = @group_b.events.create
      @group_c = @group_a.child_groups.create
      @event_2 = @group_c.events.create
    end
    it "should list direct events" do
      @group_a.events_with_subgroups.should include @event_0, @event_1, @event_2
      @group_a.direct_events.should include @event_0
      @group_a.direct_events.should_not include @event_1
    end
  end


  # Finder Methods
  # ==========================================================================================

  describe ".find_all_by_group" do
    before do
      @sub_group = create( :group )
      @sub_group.parent_groups << @group
      @sub_group_event = create(:event, group_id: @sub_group.id)
      @another_group = create( :group )
      @unrelated_event = @another_group.events.create
    end
    subject { Event.find_all_by_group( @group ) }
    it "should return direct events of the group" do
      subject.should include @event
    end
    it "should return events of the sub groups as well" do
      subject.should include @sub_group_event
    end
    it "should not return unrelated events" do
      subject.should_not include @unrelated_event
    end
  end

  describe ".find_all_by_groups" do
    before do
      @group1 = create( :group )
      @event1 = @group1.events.create( :start_at => 5.hours.from_now )
      @group2 = create( :group )
      @event2 = @group2.events.create( :start_at => 2.hours.from_now )
      @group3 = create( :group )
      @event3 = @group3.events.create
    end
    subject { Event.find_all_by_groups( [ @group1, @group2 ] ) }
    it "should return the events of the given groups" do
      subject.should include @event1, @event2
    end
    it "should not return the events of other groups" do
      subject.should_not include @event3
    end
    it "should return the events in ascending order" do
      subject.first.start_at.should < subject.last.start_at
    end
  end


  # Structure
  # ==========================================================================================

  # The following DAG structure should be possible in the model layer (bug fix).
  #
  #   @corporation
  #        |---------- @status_group
  #        |                     |
  #      @event                  |
  #        |--- @contact_people  |
  #                          |   |
  #                          @user
  #
  specify "this dag structure should work (bug fix)" do
    @user = create :user
    @corporation = create :corporation_with_status_groups
    @status_group = @corporation.status_groups.first
    @event = @corporation.child_events.create
    @contact_people = @event.contact_people_group
    @contact_people.assign_user @user
  end
  specify "this structure is created in the events controller this way" do
    @user = create :user
    @group = create :group
    @group.assign_user @user

    @event = Event.new
    @event.name ||= I18n.t(:enter_name_of_event_here)
    @event.start_at ||= Time.zone.now.change(hour: 20, min: 15)
    @event.save!
    @event.parent_groups << @group
    @event.contact_people_group.assign_user @user
  end


  describe "#destroy" do
    subject { @event.destroy }

    it "should destroy the contact people and attendees groups as well" do
      @contact_people_group = @event.contact_people_group
      @attendees_group = @event.attendees_group

      subject
      Group.exists?(id: @contact_people_group.id).should == false
      Group.exists?(id: @attendees_group.id).should == false
    end
  end

end
