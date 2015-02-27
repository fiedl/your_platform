require 'spec_helper'

describe Group do
  
  describe "#members" do
    before do
      @corporation = create :wingolf_corporation
      @aktiver = create :user; @corporation.status_group("Hospitanten").assign_user @aktiver
      @philister = create :user; @corporation.status_group("Philister").assign_user @philister
      @verstorbener = create :user; @corporation.status_group("Verstorbene").assign_user @verstorbener
      @ausgetretener = create :user; @corporation.status_group("Schlicht Ausgetretene").assign_user @ausgetretener
    end
    subject { @corporation.members }
    it { should include @aktiver }
    it { should include @philister }
    it { should_not include @verstorbener }
    it { should_not include @ausgetretener }
  end
  

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
      subject { @group.is_special_group? }
      describe "for a normal group" do
        it { should == false }
      end
    end

    describe "#is_special_group?" do
      subject { @bvs_parent_group.is_special_group? }
      describe "for the bvs parent group" do
        it { should == true }
      end
    end

    describe "#is_special_group?" do
      subject { @bv_group.is_special_group? }
      describe "for the bv group" do
        it { should == true }
      end
    end

  end
end
