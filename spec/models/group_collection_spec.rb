require 'spec_helper'

describe GroupCollection do
  
  #
  #      group1 --- page1 --- group2 --- group3 --- user1
  #        |
  #        |------- user2
  #
  before do
    @group1 = create :group, name: 'group1'
    @page1 = @group1.child_pages.create title: 'page1'
    @group2 = @page1.child_groups.create name: 'group2'
    @group3 = @group2.child_groups.create name: 'group3'
    @user1 = create :user; @group3 << @user1
    @user2 = create :user; @group1 << @user2
    
    @membership_collection = Membership.where(user: @user1)
    @group_collection = GroupCollection.new(memberships: @membership_collection)
  end
  
  describe "#to_a" do
    subject { @group_collection.to_a }
    it { should be_kind_of Array }
    it { should include @group3, @group2 }
    it { should_not include @group1, @page1, @user2 }
  end
  
  describe "#count" do
    subject { @group_collection.count }
    it { should == 2 }
  end
  
  describe "#flagged" do
    before { @group3.add_flag :test_flag }
    subject { @group_collection.flagged(:test_flag) }
    it { should be_kind_of GroupCollection }
    its(:count) { should == 1 }
    its(:to_a) { should include @group3 }
    its(:to_a) { should_not include @group2 }
    its(:to_a) { should_not include @group1, @page1, @user2 }
  end
  
  describe "(validity range scopes)" do
    #
    #      group1 --- page1 --- group2 --- group3 --- user1
    #        |                                |
    #        |------- user2                   |------ user3
    #        |
    #        |---- group4 --(past)-- user3
    #
    before do
      @group4 = @group1.child_groups.create name: 'group4'
      @user3 = create :user, last_name: 'user3'; @group4 << @user3; @group3 << @user3
      Membership.where(user: @user3, group: @group4).first.invalidate at: 1.week.ago
      
      @membership_collection = Membership.where(user: @user3)
      @group_collection = GroupCollection.new(memberships: @membership_collection)
    end
  
    describe "#now" do
      subject { @group_collection.now }
      it { should include @group3, @group2 }
      it { should_not include @group4, @group1 }
    end
    
    describe "#with_past" do
      subject { @group_collection.with_past }
      it { should include @group3, @group2 }
      it { should include @group4, @group1 }
    end
    
    describe "#past" do
      subject { @group_collection.past }
      it { should_not include @group3, @group2 }
      it { should include @group4, @group1 }
    end
    
  end
end