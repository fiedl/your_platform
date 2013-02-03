require 'spec_helper'

describe Corporation do

  describe "#is_first_corporation_this_user_has_joined?" do
    before do 
      @first_corporation = create( :corporation )
      @second_corporation = create( :corporation )
      @another_corporation = create( :corporation )
      @user = create( :user )

      @first_membership = UserGroupMembership.create( user: @user, group: @first_corporation )
      @first_membership.created_at = 1.year.ago
      @first_membership.save

      @second_membership = UserGroupMembership.create( user: @user, group: @second_corporation )
    end
    describe "for the corporation the user has joined first" do
      subject { @first_corporation.is_first_corporation_this_user_has_joined?( @user ) }
      it { should == true }
    end
    describe "for a corporation the user has not joined first" do
      subject { @second_corporation.is_first_corporation_this_user_has_joined?( @user ) }
      it { should == false }
    end
    describe "for a corporation the user is not even member of" do
      subject { @another_corporation.is_first_corporation_this_user_has_joined?( @user ) }
      it { should == false }
    end
  end

  describe "#status_groups" do
    before do
      @corporation = create( :corporation )
    end
  end


  describe ".all" do
    before do
      @corporation_group = create( :corporation )
      @non_corporation_group = create( :group )
    end
    subject { Corporation.all }

    it "should return an array of Corporation-type objects" do
      subject.should be_kind_of Array
      subject.first.should be_kind_of Corporation
    end
    it "should find the corporation groups" do
      subject.should include @corporation_group
    end
    it "should not find the non-corporation groups" do
      subject.should_not include @non_corporation_group
    end
  end

end
