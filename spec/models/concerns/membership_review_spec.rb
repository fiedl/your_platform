require 'spec_helper'

describe MembershipReview do
  before do
    @user = create :user
    @group = create :group
    @membership = Membership.create user: @user, group: @group
  end
  
  describe "needs_review?" do
    subject { @membership.needs_review? }
    describe "when unset" do
      it { should == false }
    end
    describe "when set to true" do
      before { @membership.needs_review = true; @membership.reload }
      it { should == true }
    end
  end
  
  describe "needs_review=" do
    describe "true" do
      subject { @membership.needs_review = true; @membership.reload }
      describe "when unset" do
        specify { subject; @membership.needs_review?.should == true }
      end
      describe "when set to true" do
        before { @membership.needs_review = true }
        specify { subject; @membership.needs_review?.should == true }
      end        
      describe "when set to false" do
        before { @membership.needs_review = false }
        specify { subject; @membership.needs_review?.should == true }
      end
    end
    describe "false" do
      subject { @membership.needs_review = false; @membership.reload }
      describe "when unset" do
        specify { subject; @membership.needs_review?.should == false }
      end
      describe "when set to true" do
        before { @membership.needs_review = true }
        specify { subject; @membership.needs_review?.should == false }
      end        
      describe "when set to false" do
        before { @membership.needs_review = false }
        specify { subject; @membership.needs_review?.should == false }
      end
    end
  end

  describe "needs_review!" do
    subject { @membership.needs_review!; @membership.reload }
    describe "when unset" do
      specify { subject; @membership.needs_review?.should == true }
    end
    describe "when set to true" do
      before { @membership.needs_review = true }
      specify { subject; @membership.needs_review?.should == true }
    end        
    describe "when set to false" do
      before { @membership.needs_review = false }
      specify { subject; @membership.needs_review?.should == true }
    end
  end
end