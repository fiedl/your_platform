require 'spec_helper'

describe StructureableConnectedGroups do
  
  # Example:
  # 
  #     group1
  #       |---- group2 --- group3 --------------
  #       |---- event1                          |
  #       |       |------ attendees_group ---- user1
  #       |
  #     officers_parent ---- officer_group --- user2     
  #
  #   In the example, groups 1, 2, and 3 are connected groups. But the attendees_group
  #   is not connected to them, because a non-group object, event1, is in between.
  #
  #   Despite `officers_parent` being a group, `user2` is not regarded as
  #   connected to `group1`, since officers aren't necessarily members of a group.
  #
  before do
    @group1 = create :group, name: 'group1'
    @group2 = @group1.child_groups.create name: 'group2'
    @group3 = @group2.child_groups.create name: 'group3'
    @event1 = @group1.child_events.create name: 'event1'
    @attendees_group = @event1.attendees_group
    @user1 = create :user; @group3 << @user1; @attendees_group << @user1
    @officers_parent = @group1.officers_parent
    @officer_group = @officers_parent.child_groups.create name: 'officer_group'
    @user2 = create :user; @officer_group << @user2
  end
  
  describe "#connected_ancestor_groups" do
    describe "for @group3" do
      subject { @group3.connected_ancestor_groups }
      it { should include @group1, @group2 }
      it { should_not include @group3 }
      it { should_not include @attendees_group }
    end

    describe "for @group2" do
      subject { @group2.connected_ancestor_groups }
      it { should include @group1 }
      it { should_not include @group2 }
      it { should_not include @group3, @attendees_group }
    end
    
    describe "for @attendees_group" do
      subject { @attendees_group.connected_ancestor_groups }
      it { should == [] }
    end
    
    describe "for @user1" do
      subject { @user1.connected_ancestor_groups }
      it { should include @group1, @group2, @group3 }
      it { should include @attendees_group }
      it { should_not include @event1 }
    end
    
    describe "when officer groups are on the path" do
      describe "for @user2" do
        subject { @user2.connected_ancestor_groups }
        it { should include @officer_group }
        it { should_not include @group1 }
      end
    end
  end
  
  describe "#connected_descendant_groups" do
    describe "for @group1" do
      subject { @group1.connected_descendant_groups }
      it { should include @group2, @group3 }
      it { should_not include @group1 }
      it { should_not include @attendees_group }
      it "should not include officer_parents or officer_groups" do
        subject.should_not include @officers_parent
        subject.should_not include @officer_group
      end
    end
  end
  
end