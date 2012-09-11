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


  # Corporations Parent
  # ==========================================================================================

  describe "corporations_parent_group" do
    before do
      Group.destroy_all
      @everyone_group = Group.create_everyone_group
      @corporations_parent_group = Group.create_corporations_parent_group
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
  end


  # Officers Parent
  # ==========================================================================================

  describe "officers_parent_group" do
    before do
      @container_group = create( :group ) 
      @officers_parent = @container_group.create_officers_parent_group
      @container_group.reload
      @officers_parent.reload
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
      it { should == @officers_parent.child_groups }
    end

    subject { @container_group }
    its( :officers_parent ) { should == @officers_parent }
    its( :officers_parent! ) { should == @officers_parent }
    its( :officers ) { should == @container_group.find_officers_groups }

  end

end
