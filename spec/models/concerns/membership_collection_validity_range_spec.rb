require 'spec_helper'

describe MembershipCollectionValidityRange do
  
  #   @group1 --- @subgroup1 ------
  #                                |
  #   @group2 ------------------ @user1
  #      |
  #      |---------------------- @user2
  #
  before do
    @group1 = create :group, name: 'group1'
    @subgroup1 = @group1.child_groups.create name: 'group2'
    @group2 = create :group, name: 'group2'
    @user1 = create :user; @subgroup1 << @user1; @group2 << @user1
    @user2 = create :user; @group2 << @user2
  end
  
  describe "#valid" do
    describe "if the dag link between @subgroup1 and @user1 has been invalidated" do
      before { @subgroup1.links_as_parent.first.update_attribute :valid_to, 5.minutes.ago }
      it "should limit the results to valid links" do
        Membership.where(group: @group1).valid.count.should == 0
        Membership.where(group: @subgroup1).valid.count.should == 0
        Membership.where(group: @group2).valid.count.should == 2
        Membership.where(user: @user1).valid.count.should == 1
        Membership.where(user: @user2).valid.count.should == 1
      end
    end
  end
  
  describe "#invalid" do
    describe "if the dag link between @subgroup1 and @user1 has been invalidated" do
      before { @subgroup1.links_as_parent.first.update_attribute :valid_to, 5.minutes.ago }
      it "should limit the results to invalid links" do
        Membership.where(group: @group1).invalid.count.should == 1
        Membership.where(group: @subgroup1).invalid.count.should == 1
        Membership.where(group: @group2).invalid.count.should == 0
        Membership.where(user: @user1).invalid.count.should == 2
        Membership.where(user: @user2).invalid.count.should == 0
      end
    end
  end
  
  describe "#with_invalid" do
    describe "if the dag link between @subgroup1 and @user1 has been invalidated" do
      before { @subgroup1.links_as_parent.first.update_attribute :valid_to, 5.minutes.ago }
      it "should include valid and invalid memberships in the results" do
        Membership.where(group: @group1).with_invalid.count.should == 1
        Membership.where(group: @subgroup1).with_invalid.count.should == 1
        Membership.where(group: @group2).with_invalid.count.should == 2
        Membership.where(user: @user1).with_invalid.count.should == 3
        Membership.where(user: @user2).with_invalid.count.should == 1
      end
    end
  end
  
end