require 'spec_helper'

describe GroupMixins::SpecialGroups do

  before do 
    @group = create(:group)
    @child_group = create(:group); @child_group.parent_groups << @group
    @user = create(:user)
  end

  # This spec is due to a previous bug.
  # For more specs on roles, please see spec/structureable_mixins/roles_specs.rb.
  #
  describe "#admins_parent!", focus: true do
    subject { @group.admins_parent! }
    it "should refer to the admins_parent sub group of the group" do
      officers_group = subject.parent_groups.first
      officers_group.parent_groups.first.should == @group
    end
    it "should not refer to a admins_parent group of one of the child groups" do
      officers_group = subject.parent_groups.first
      officers_group.parent_groups.first.should_not == @child_group
    end

    describe "for a admins_parent group already being defined for a child group" do
      before do
        @child_group.create_admins_parent_group
      end
      it "should still not refer to the admins_parent group of the child group" do
        officers_group = subject.parent_groups.first
        officers_group.parent_groups.first.should_not == @child_group
      end
      it "should refer to the admins_parent sub group of the group" do
        officers_group = subject.parent_groups.first
        officers_group.parent_groups.first.should == @group
      end
    end
  end

end
