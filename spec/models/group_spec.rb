require 'spec_helper'

describe Group do

  # Special Groups
  # ==========================================================================================

  # BVs
  # ------------------------------------------------------------------------------------------

  describe "(BVs) " do
    before do
      # in this context, this should be a group, but FactoryGirl returns a Bv-type object.
      @bv_group = create( :bv_group ).becomes Group 
      @bvs_parent_group = @bv_group.parent_groups.first
      @group = create( :group )
    end

    describe ".find_bvs_parent_group" do
      subject { Group.find_bvs_parent_group }
      it { should_not == nil }
      it { should == @bvs_parent_group }
    end

    describe ".find_bv_groups" do
      subject { Group.find_bv_groups }
      it { should == [ @bv_group ] }
    end

    describe ".create_bvs_parent_group" do
      it "should create the parent group for the bvs" do
        Group.find_bvs_parent_group.should_not == nil
        @bvs_parent_group.destroy
        Group.find_bvs_parent_group.should == nil

        Group.create_bvs_parent_group
        Group.find_bvs_parent_group.should_not == nil
      end
    end

    describe "#is_special_group?" do
      subject { @bv_group.is_special_group? }
      describe "for the bv group" do
        it { should == true }
      end

      describe "for the bvs parent group" do
        before { @bvs_parent_group.is_special_group? }
        it { should == true }
      end

      describe "for the group" do
        before { @group.is_special_group? }
        it { should == true }
      end
    end
  end

end
