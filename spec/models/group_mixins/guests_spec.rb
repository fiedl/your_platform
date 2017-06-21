require 'spec_helper'

describe GroupMixins::Guests do

  # Guests Parent
  # ==========================================================================================

  describe "guests_parent_group" do

    before do
      @container_group = create( :group ) 
      @container_subgroup = create( :group ) # this is to test if subgroup's guests are NOT listed
      @container_subgroup.parent_groups << @container_group
      @guests_parent = @container_group.create_guests_parent_group
      @subgroup_guests_parent = @container_subgroup.create_guests_parent_group
      @guests_sub1 = create( :group ); @guests_sub1.parent_groups << @guests_parent
      @guests_sub2 = create( :group ); @guests_sub2.parent_groups << @subgroup_guests_parent
      @guest1 = create( :user ); @guest1.parent_groups << @guests_parent
      @guest2 = create( :user ); @guest2.parent_groups << @guests_sub1
      @container_group.reload
      @container_subgroup.reload
      @guests_parent.reload
      @subgroup_guests_parent.reload
      @other_group = create( :group )
    end

    describe "#create_guests_parent_group" do
      it "should create the guests_parent_group" do
        @guests_parent.has_flag?( :guests_parent ).should be true
        @guests_parent.parent_groups.should include( @container_group )
      end
    end

    describe "#find_guests_parent_group" do
      subject { @container_group.find_guests_parent_group }
      it "should find the guests_parent_group" do
        subject.should == @guests_parent
        subject.has_flag?( :guests_parent ).should be true
      end
    end

    describe "#find_guests_groups" do
      subject { @container_group.find_guests_groups }
      it "should find the guests of the container group" do
        subject.should include( @guests_sub1 )
      end
      it "should NOT find the guests of the container group's subgroups" do
        subject.should_not include( @guests_sub2 ) 
      end
    end

    describe "#find_guest_users" do
      describe "if the group has a guests_parent group" do
        subject { @container_group.find_guest_users }
        it "should find all descendant users of the group" do
          subject.should include( @guest1, @guest2 )
        end
      end
      describe "if the group does not have a guests_parent group" do
        subject { @other_group.find_guest_users }
        it "should still return an empty array" do
          subject.should == []
        end
      end
    end

    subject { @container_group }
    its( :guests_parent ) { should == @guests_parent }
    its( :guests_parent! ) { should == @guests_parent }
    
    its( :guests ) { should == @container_group.find_guest_users }

  end

end
