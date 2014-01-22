require 'spec_helper'

describe GroupMixins::Officers do
  
  before do
    @group = create(:group)
  end
  
  describe "#has_no_subgroups_other_than_the_officers_parent?" do
    subject { @group.has_no_subgroups_other_than_the_officers_parent? }
    
    describe "for the group having no subgroups" do
      it { should == true }
    end
    
    describe "for the group having subgroups" do
      before { @group.child_groups.create }
      it { should == false }
    end
    
    describe "for the group having an officers group" do
      before { @group.create_officers_parent_group }
      it { should == true }
    end
    
    describe "for the group having an admins group" do
      before { @group.find_or_create_admins_parent_group }
      it { should == true }
    end
    
    describe "after asking for the admins_parent (bug fix)" do
      before { @admins_parent = @group.admins_parent }
      it { should == true }
    end
    
  end
  
end
