# -*- coding: utf-8 -*-
require 'spec_helper'

describe GroupMixins::Import do

  # Hash Array Import
  # ==========================================================================================

  describe ".hash_array_import_groups_into_parent_group" do

    before do
      @root_group = create( :group, name: "Root Group" )
      hash_array = [
                    {
                      :name => "Group 1",
                      :children => [
                                    { :name => "Group 1.1" },
                                    { :name => "Group 1.2" }
                                 ]
                    },
                    { :name => "Group 2" }
                   ]
      Group.hash_array_import_groups_into_parent_group( hash_array, @root_group )
    end

    it "should import the group structure correctly" do
      @root_group.reload
      @root_group.child_groups.collect { |g| g.name }.should == [ "Group 1", "Group 2" ]
      @root_group.child_groups.first.child_groups.collect { |g| g.name }.should == 
        [ "Group 1.1", "Group 1.2" ]
    end

  end

  describe ".convert_group_names_to_group_hashes" do
    
    before do
      group_names = [ "Group 1", { "Group 2" => [ "Group 2.1", "Group 2.2" ] } ]
      @group_hashes = Group.convert_group_names_to_group_hashes( group_names )
    end

    it "should convert the group_names correctly" do
      @group_hashes.should == [ 
                               { name: "Group 1" },
                               { name: "Group 2",
                                 children: [
                                            { name: "Group 2.1" },
                                            { name: "Group 2.2" }
                                           ]
                               }
                              ]
    end
    
  end


  # Special Groups
  # ==========================================================================================

  describe "#set_flags_based_on_group_name" do
    before { @group = create( :group ) }
    subject { @group.set_flags_based_on_group_name }
    context "for group name 'Officers'" do
      before { @group.name = "Officers" }
      it "should set the :officers_parent flag" do
        subject
        @group.has_flag?( :officers_parent ).should be_true
      end
    end
    context "for group name 'Amtsträger'" do
      before { @group.name = "Amtsträger" }
      it "should set the :officers_parent flag" do
        subject
        @group.has_flag?( :officers_parent ).should be_true
      end
    end
    context "for group name 'Gäste'" do
      before { @group.name = "Gäste" }
      it "should set the :guests_parent flag" do
        subject
        @group.has_flag?( :guests_parent ).should be_true
      end
    end
    context "for group name 'Guests'" do
      before { @group.name = "Guests" }
      it "should set the :guests_parent flag" do
        subject
        @group.has_flag?( :guests_parent ).should be_true
      end
    end
  end

end
