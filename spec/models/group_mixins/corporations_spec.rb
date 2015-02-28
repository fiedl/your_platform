# -*- coding: utf-8 -*-
require 'spec_helper'

describe GroupMixins::Corporations do


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
      
      # FIXME: This does not work for some obscure reason. 
      # Whenever the corporations are needed without the officers_parent group,
      # please use `Corporation.all`, which works.
      #
      # # it "should not include the officers_parent" do
      # #   @officers_parent = @corporations_parent_group.find_or_create_officers_parent_group
      # #   subject.should_not include @officers_parent
      # # end
    end

    describe ".corporations" do
      subject { Group.corporations }
      it "should be the same as .find_corporation_groups" do
        subject.should == Group.find_corporation_groups
      end
      it "should be of the proper type" do  # bug test: is the `corporations` method overridden correctly? 
        subject.should be_kind_of Array
        subject.first.should_not be_kind_of User
        subject.first.should be_kind_of Group
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

end
