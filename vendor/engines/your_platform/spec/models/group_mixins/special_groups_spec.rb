# -*- coding: utf-8 -*-
require 'spec_helper'

describe GroupMixins::SpecialGroups do


  # Everyone
  # ==========================================================================================

  describe "everyone_group" do
    before do
      Group.destroy_all
      @everyone_group = Group.create_everyone_group
    end

    describe ".create_everyone_group" do
      it "should create the group 'everyone' and return it" do
        @everyone_group.ancestor_groups.count.should == 0
        @everyone_group.has_flag?( :everyone ).should == true
      end
    end
    
    describe ".find_everyone_group" do
      subject { Group.find_everyone_group }
      it "should return the everyone_group" do
        subject.should == @everyone_group
        subject.has_flag?( :everyone ).should == true
      end
    end
  end


  # Corporations Parent, Corporations
  # ==========================================================================================

  describe "corporations: " do
    before do
      Group.destroy_all
      @everyone_group = Group.create_everyone_group
      @corporations_parent_group = Group.create_corporations_parent_group
      @corporation_group = create( :group ); @corporation_group.parent_groups << @corporations_parent_group

      @corporation_group_of_user = create( :group )
      @corporation_group_of_user.parent_groups << @corporations_parent_group
      @subgroup = create( :group ); @subgroup.parent_groups << @corporation_group_of_user
      @user = create( :user ); @user.parent_groups << @subgroup
      @non_corporations_branch_group = create( :group ); @non_corporations_branch_group.child_users << @user
    end

    describe ".create_corporations_parent_group" do
      it "should create the group 'corporations_parent' and return it" do
        @corporations_parent_group.has_flag?( :corporations_parent ).should be_true
      end
    end

    describe ".find_corporations_parent_group" do
      subject { Group.find_corporations_parent_group }
      it "should return the corporations_parent_group" do
        subject.should == @corporations_parent_group
        subject.has_flag?( :corporations_parent ).should be_true
      end
    end

    describe ".find_corporation_groups" do
      subject { Group.find_corporation_groups }
      it "should return an array containing the corporation groups" do
        subject.should == [ @corporation_group, @corporation_group_of_user ]
      end
    end

    describe ".find_corporation_groups_of( user )" do
      subject { Group.find_corporation_groups_of( @user ) }
      it { should == [ @corporation_group_of_user ] }
    end

    describe ".find_corporations_branch_groups_of( user )" do
      subject { Group.find_corporations_branch_groups_of( @user ) }
      it "should return the corporations of the user and the subgroups of the corporations" do
        subject.should include( @corporation_group_of_user, @subgroup )
        subject.should_not include( @corporation_group )
      end
      it "should include the corporations_parent_group" do
        subject.should include( @corporations_parent_group )
      end
    end

    describe ".find_non_corporations_branch_groups_of( user )" do
      subject { Group.find_non_corporations_branch_groups_of( @user ) }
      it "should return the groups of the user that are not part of the corporations branch" do
        subject.should include( @non_corporations_branch_group )
        subject.should_not include( @corporation_group_of_user, @subgroup )
      end
      it "should not include the corporations_parent_group" do
        subject.should_not include( @corporations_parent_group )
      end
    end

  end

  
  # Officers Parent
  # ==========================================================================================

  describe "officers_parent_group" do
    before do
      @container_group = create( :group ) 
      @container_subgroup = create( :group ) # this is to test if subgroup's officers are listed as well
      @container_subgroup.parent_groups << @container_group
      @officers_parent = @container_group.create_officers_parent_group
      @subgroup_officers_parent = @container_subgroup.create_officers_parent_group
      @officer1 = create( :group ); @officer1.parent_groups << @officers_parent
      @officer2 = create( :group ); @officer2.parent_groups << @subgroup_officers_parent
      @container_group.reload
      @container_subgroup.reload
      @officers_parent.reload
      @subgroup_officers_parent.reload
    end

    describe "#create_officers_parent_group" do
      it "should create the officers_parent_group" do
        @officers_parent.has_flag?( :officers_parent ).should be_true
        @officers_parent.parent_groups.should include( @container_group )
      end
    end

    describe "#find_officers_parent_group" do
      subject { @container_group.find_officers_parent_group }
      it "should find the officers_parent_group" do
        subject.should == @officers_parent
        subject.has_flag?( :officers_parent ).should be_true
      end
    end

    describe "#find_officers_groups" do
      subject { @container_group.find_officers_groups }
      it "should find the officers of the container group" do
        #subject.should include( @officers_parent.child_groups )
        subject.should include( @officer1 )
      end
      it "should find the officers of the container group's subgroups as well" do
        #subject.should include( @subgroup_officers_parent.child_groups )
        subject.should include( @officer2 ) 
      end
    end

    subject { @container_group }
    its( :officers_parent ) { should == @officers_parent }
    its( :officers_parent! ) { should == @officers_parent }
    its( :officers ) { should == @container_group.find_officers_groups }

  end


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
    end

    describe "#create_guests_parent_group" do
      it "should create the guests_parent_group" do
        @guests_parent.has_flag?( :guests_parent ).should be_true
        @guests_parent.parent_groups.should include( @container_group )
      end
    end

    describe "#find_guests_parent_group" do
      subject { @container_group.find_guests_parent_group }
      it "should find the guests_parent_group" do
        subject.should == @guests_parent
        subject.has_flag?( :guests_parent ).should be_true
      end
    end

    describe "#find_guests_groups" do
      subject { @container_group.find_guests_groups }
      it "should find the guests of the container group" do
        subject.should include( @guests_sub1 )
      end
      it "should NOT find the guests of the container group's subgroups" do
        #subject.should include( @subgroup_guests_parent.child_groups )
        subject.should_not include( @guests_sub2 ) 
      end
    end

    describe "#find_guest_users" do
      subject { @container_group.find_guest_users }
      it "should find all descendant users of the group" do
        subject.should include( @guest1, @guest2 )
      end
    end

    subject { @container_group }
    its( :guests_parent ) { should == @guests_parent }
    its( :guests_parent! ) { should == @guests_parent }
    
    its( :guests ) { should == @container_group.find_guest_users }

  end

end
