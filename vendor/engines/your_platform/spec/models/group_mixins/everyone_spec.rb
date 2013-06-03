# -*- coding: utf-8 -*-
require 'spec_helper'

describe GroupMixins::Everyone do


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

end
