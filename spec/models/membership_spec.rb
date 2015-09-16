require 'spec_helper'

describe Membership do

  # Example: 
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
  end
  
  describe ".find" do
    subject { Membership.find(@dag_link_id) }
    #
    #   group2 --- group3 --- user1
    #
    describe "for a direct membership" do
      before { @dag_link_id = Membership.where(user: @user1, group: @group3).first.dag_link.id }
      it { should be_kind_of Membership }
      its(:user) { should == @user1 }
      its(:group) { should == @group3 }
      its(:direct?) { should be_true }
      it "should perform only 4 queries: DagLink, User, Group and Flags" do
        count_queries(4) { subject }.should <= 4
      end
    end
    describe "for a non-existent dag link" do
      before { @dag_link_id = DagLink.pluck(:id).max + 5 }
      it "should raise an error" do
        expect { subject }.to raise_error
      end
    end
  end
  
  
  describe "#save!" do
    subject { @membership.save! }
    
    describe "for direct memberships" do
      before { @membership = Membership.where(user: @user2, group: @group1).first }
      it "should save a changed valid_from and valid_to attributes" do
        @membership.valid_from = @time1 = 2.months.ago
        @membership.valid_to = @time2 = 1.month.ago
        subject
        @membership.reload.valid_from.to_i.should == @time1.to_i
        @membership.reload.valid_to.to_i.should == @time2.to_i
        @membership.dag_link.reload.valid_from.to_i.should == @time1.to_i
        @membership.dag_link.reload.valid_to.to_i.should == @time2.to_i
      end
    end
    
    describe "for indirect memberships" do
      before { @membership = Membership.where(user: @user1, group: @group2).first }
      specify "requirements" do
        @membership.user.should == @user1
        @membership.group.should == @group2
      end
      it "should raise an error, since indirect memberships are non-persistent objects" do
        expect { subject }.to raise_error
      end
    end
  end
  
  describe ".create" do
    #
    #    @group1 --- @subgroup1     @user1
    #
    before do
      @group1 = create :group, name: 'group1'
      @subgroup1 = @group1.child_groups.create name: 'subgroup1'
      @user1 = create :user
    end
    describe "creating a direct membership" do
      subject { Membership.create group: @group1, user: @user1 }
      it "should create the corresponding dag link" do
        @user1.links_as_child.count.should == 0
        subject
        @user1.links_as_child.count.should == 1
        @user1.links_as_child.first.ancestor.should == @group1
      end
      it { should be_kind_of Membership }
      its(:group) { should == @group1 }
      its(:user) { should == @user1 }
      
      describe "if the membership already exists indirectly" do
        before { Membership.create group: @subgroup1, user: @user1 }
        it "should create the corresponding dag link" do
          @user1.links_as_child.count.should == 1
          subject
          @user1.links_as_child.count.should == 2
          @user1.links_as_child.last.ancestor.should == @group1
        end
        it { should be_kind_of Membership }
        its(:group) { should == @group1 }
        its(:user) { should == @user1 }
      end
    end
    
    describe "creating a direct membership with validity range" do
      before { @time1 = 1.month.ago; @time2 = 10.days.ago }
      subject { Membership.create group: @group1, user: @user1, valid_from: @time1, valid_to: @time2 }
      it { should be_kind_of Membership }
      its(:group) { should == @group1 }
      its(:user) { should == @user1 }
      its('valid_from.to_i') { should == @time1.to_i }
      its('valid_to.to_i') { should == @time2.to_i }
      its('dag_link.valid_from.to_i') { should == @time1.to_i }
      its('dag_link.valid_to.to_i') { should == @time2.to_i }
    end
  end
  
end