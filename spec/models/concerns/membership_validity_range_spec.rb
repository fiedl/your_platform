require 'spec_helper'

describe MembershipValidityRange do
  
  #   @group1 --- @subgroup1 ------
  #                                |
  #   @group2 ------------------ @user1
  #      |
  #      |---------------------- @user2
  #
  before do
    @group1 = create :group, name: 'group1'
    @subgroup1 = @group1.child_groups.create name: 'subgroup1'
    @group2 = create :group, name: 'group2'
    @user1 = create :user, last_name: 'user1'; @subgroup1 << @user1; @group2 << @user1
    @user2 = create :user, last_name: 'user2'; @group2 << @user2
  end
  
  describe "#invalidate" do
    describe "for direct memberships" do
      before { @membership = Membership.where(user: @user1, group: @subgroup1).first }

      describe "without argument" do
        subject { @membership.invalidate }

        it "sets the valid_to attribute on the DagLink to the current time" do
          DagLink.where(ancestor_type: 'Group', descendant_type: 'User', direct: true,
            ancestor_id: @subgroup1.id, descendant_id: @user1.id).first
            .valid_to.should == nil
          subject
          DagLink.where(ancestor_type: 'Group', descendant_type: 'User', direct: true,
            ancestor_id: @subgroup1.id, descendant_id: @user1.id).first
            .valid_to.should > 1.second.ago
        end
        it "sets the valid_to attribute on the membership to the current time" do
          @membership.valid_to.should == nil
          subject
          @membership.reload.valid_to.should > 1.second.ago
        end        
      end
      
      describe "with time as argument" do
        before { @time = 20.minutes.ago }
        subject { @membership.invalidate at: @time }
        
        it "sets the valid_to attribute on the DagLink to the given time" do
          DagLink.where(ancestor_type: 'Group', descendant_type: 'User', direct: true,
            ancestor_id: @subgroup1.id, descendant_id: @user1.id).first
            .valid_to.should == nil
          subject
          DagLink.where(ancestor_type: 'Group', descendant_type: 'User', direct: true,
            ancestor_id: @subgroup1.id, descendant_id: @user1.id).first
            .valid_to.to_i.should == @time.to_i
        end
        it "sets the valid_to attribute on the membership to the given time" do
          @membership.valid_to.should == nil
          subject
          @membership.reload.valid_to.to_i.should == @time.to_i
        end
      end
      
    end
  end
  
  describe "#currently_valid?" do
    subject { @membership.currently_valid? }
    describe "for direct memberships" do
      describe "for a membership without validity range" do
        before { @membership = Membership.where(user: @user1, group: @subgroup1).first }
        it { should be_true }
      end
      describe "for a current membership" do
        before do
          @membership = Membership.where(user: @user1, group: @subgroup1).first
          @membership.dag_link.update_attributes valid_from: 1.month.ago
          @membership = Membership.where(user: @user1, group: @subgroup1).first
        end
        it { should be_true }
      end
      describe "for a past membership" do
        before do
          @membership = Membership.where(user: @user1, group: @subgroup1).first
          @membership.dag_link.update_attributes valid_from: 1.month.ago, valid_to: 10.days.ago
          @membership = Membership.where(user: @user1, group: @subgroup1).first
        end
        it { should be_false }
      end
    end
    describe "for indirect memberships" do
      describe "for a membership without validity range" do
        before { @membership = Membership.where(user: @user1, group: @group1).first }
        it { should be_true }
      end
      describe "for a current membership" do
        before do
          Membership.where(user: @user1, group: @subgroup1).first.dag_link.update_attribute :valid_from, 1.month.ago
          @membership = Membership.where(user: @user1, group: @group1).first
        end
        it { should be_true }
      end
      describe "for a past membership" do
        before do
          Membership.where(user: @user1, group: @subgroup1).first.dag_link.update_attribute :valid_from, 1.month.ago
          Membership.where(user: @user1, group: @subgroup1).first.dag_link.update_attribute :valid_to, 10.days.ago
          @membership = Membership.where(user: @user1, group: @group1).first
        end
        it { should be_false }
      end
    end
  end
  
  describe "#where" do
    #
    #    @group1 --- @subgroup1     @user1
    #       |
    #       |------- @subgroup2 
    #
    before do
      @group1 = create :group, name: 'group1'
      @subgroup1 = @group1.child_groups.create name: 'subgroup1'
      @subgroup2 = @group1.child_groups.create name: 'subgroup2'
      @user1 = create :user
    end
    subject { Membership.where(user: @user1, group: @group1) }
    
    describe "for user and group" do
      before { @t1 = 2.years.ago; @t2 = 1.year.ago; @t3 = 1.month.ago; @t4 = nil }
      describe "if the user has multiple direct memberships in that group" do
        before do
          @membership1 = Membership.create group: @group1, user: @user1, valid_from: @t1, valid_to: @t2
          @membership2 = Membership.create group: @group1, user: @user1, valid_from: @t3
        end
        its(:count) { should == 2 }
        specify "the memberships should have the correct validity range" do
          subject.to_a.collect { |membership| membership.valid_from.try(:to_i) }.should include @t1.to_i, @t3.to_i
          subject.to_a.collect { |membership| membership.valid_to.try(:to_i) }.should include @t2.to_i, @t4
        end
      end
      describe "if the user has multiple indirect memberships in that group" do
        before do
          @membership1 = Membership.create group: @subgroup1, user: @user1, valid_from: @t1, valid_to: @t2
          @membership2 = Membership.create group: @subgroup2, user: @user1, valid_from: @t3
        end
        its(:count) { should == 2 }
        specify "the memberships should have the correct validity range" do
          subject.to_a.collect { |membership| membership.valid_from.try(:to_i) }.should include @t1.to_i, @t3.to_i
          subject.to_a.collect { |membership| membership.valid_to.try(:to_i) }.should include @t2.to_i, @t4
        end
      end
      describe "if the user has direct and indirect memberships in that group" do
        before do
          @membership1 = Membership.create group: @group1, user: @user1, valid_from: @t1, valid_to: @t2
          @membership2 = Membership.create group: @subgroup1, user: @user1, valid_from: @t3
        end
        its(:count) { should == 2 }
        specify "the memberships should have the correct validity range" do
          subject.to_a.collect { |membership| membership.valid_from.try(:to_i) }.should include @t1.to_i, @t3.to_i
          subject.to_a.collect { |membership| membership.valid_to.try(:to_i) }.should include @t2.to_i, @t4
        end
      end
    end
  end
  
end
