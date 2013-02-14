require 'spec_helper'

describe Event do

  before do
    @group = create( :group )
    @another_group = create( :group )
    @event = create( :event )
    @event.group = @group
    @event.reload # otherwise some associations are apparently missing
  end

  # Groups
  # ==========================================================================================

  describe "#group" do
    subject { @event.group }
    it "should return the associated group" do
      subject.should == @group
      @event.parent_groups.should == [ @group ]
      @event.links_as_child.count.should == 1
      @group.links_as_parent.count.should == 1
      @event.links_as_child.first.should == @group.links_as_parent.first
    end
  end

  describe "#group=" do
    subject { @event.group = @another_group }
    it "should associate the new group and remove previous group associations" do
      @event.group.should == @group
      @event.parent_groups.count.should == 1
      subject
      @event.group.should == @another_group
      @event.parent_groups.count.should == 1
      @event.parent_groups.should include @another_group
      @event.parent_groups.should_not include @group
    end
  end

  describe "#groups" do
    subject { @event.groups }
    it "should be a shortcut for #parent_groups" do
      subject.should == @event.parent_groups
    end
    it "should return an array of the associated groups" do
      subject.should be_kind_of Array
      subject.should include @group
    end
  end
  describe "#groups <<" do
    subject { @event.groups << @another_group }
    it "should add the given group" do
      @event.groups.should == [ @group ]
      subject
      @event.groups.should include @group, @another_group
    end
  end


  # Scopes
  # ==========================================================================================

  describe ".upcoming" do
    before do 
      @upcoming_event = create( :event, start_at: 5.hours.from_now )
      @recent_event = create( :event, start_at: 5.hours.ago )
      @group.child_events << @upcoming_event << @recent_event
      @unrelated_event = create( :event, start_at: 5.hours.from_now )
    end
    subject { Event.upcoming }
    it "should return events starting in the future" do
      subject.should include @upcoming_event
    end
    it "should not return events having started in the past" do
      subject.should_not include @recent_event
    end
    describe "chained with .find_all_by_group" do
      subject { Event.find_all_by_group( @group ).upcoming }
      it "should commute with find_all_by_group" do
        Event.find_all_by_group( @group ).upcoming.should ==
          Event.upcoming.find_all_by_group( @group )
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

  describe ".direct" do
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
      @event_0 = @group_a.child_events.create
      @group_b = @group_a.child_groups.create
      @event_1 = @group_b.child_events.create
      @group_c = @group_a.child_groups.create
      @event_2 = @group_c.child_events.create
    end
    it "should list direct events" do
      @group_a.events.should include @event_0, @event_1, @event_2
      @group_a.events.direct.should include @event_0
      @group_a.events.direct.should_not include @event_1
    end
    it "should commute with .find_all_by_group" do
      Event.find_all_by_group( @group_a ).direct.to_a.should ==
        Event.direct.find_all_by_group( @group_a ).to_a
    end
  end
  

  # Finder Methods
  # ==========================================================================================

  describe ".find_all_by_group" do
    before do
      @sub_group = create( :group )
      @sub_group.parent_groups << @group
      @sub_group_event = create( :event )
      @sub_group_event.parent_groups << @sub_group
      @another_group = create( :group )
      @unrelated_event = @another_group.events.create
    end
    subject { Event.find_all_by_group( @group ) }
    it "should return direct events of the group" do
      subject.should include @event
    end
    it "should return events of the sub groups as well" do
      subject.should include @sub_group_event
      @sub_group_event.ancestors.should include @group, @sub_group
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

end
