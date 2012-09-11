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

    for name_translation in [ "Officers", "Amtsträger" ] do
      describe "(group.name=='#{name_translation}')" do

        before do
          @officers_parent_group = create( :group, name: name_translation )
          @officers_parent_group.set_flags_based_on_group_name
        end

        it "should set the officers flag" do
          @officers_parent_group.has_flag?( :officers_parent ).should be_true
        end

      end
    end

  end

end
