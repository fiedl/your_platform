require 'spec_helper'

describe StatusGroupMembership do

  # Finder Methods
  # ==========================================================================================
  
  class SomeCorporationDerivative < Corporation
    # This is just a dummy. The main app could invent a class inherited from Corporation.
    # Some methods need to work with them as well as with the original Corporation class.
  end

  describe "Finder Methods: " do
    before do
      @corporation = create( :corporation )
      @intermediate_group = create( :group, name: "Not a Status Group" )
      @status_group = create( :group, name: "Status Group" )

      @intermediate_group.parent_groups << @corporation
      @status_group.parent_groups << @intermediate_group
      @user = create( :user )
      @status_group.assign_user @user

      @membership = UserGroupMembership.find_by_user_and_group( @user, @status_group )
        .becomes( StatusGroupMembership )
      @intermediate_group_membership = UserGroupMembership
        .find_by_user_and_group( @user, @intermediate_group )
    end

    describe ".find_all_by_corporation" do
      subject { StatusGroupMembership.find_all_by_corporation( @corporation ) }
      it "should be chainable, i.e. return an ActiveRecord::Relation object" do
        subject.should be_kind_of ActiveRecord::Relation
      end
      it "should return the membership of the descendant_users in their status groups" do
        subject.should include @membership
      end
      it "should work for corporation derivatives as well" do
        @corporation_derivative = @corporation.becomes SomeCorporationDerivative
        expect { StatusGroupMembership.find_all_by_corporation( @corporation_derivative ) }
          .not_to raise_error
      end
      it "should not return memberships in intermediate groups" do
        # this behavior might be changed by the main app. 
        subject.should_not include @intermediate_group_membership
      end
    end

    describe ".find_all_by_user" do
      subject { StatusGroupMembership.find_all_by_user( @user ) }
      it "should be chainable, i.e. return an ActiveRecord::Relation object" do
        subject.should be_kind_of ActiveRecord::Relation
      end
      it "should return the memberships of the user in his status groups" do
        subject.should include @membership
      end
      it "should not list memberships of the user in non-status groups" do
        @non_status_membership = UserGroupMembership
          .find_by_user_and_group( @user, @corporation )
        subject.should_not include @non_status_membership
      end
      it "should not return memberships in intermediate groups" do
        # this behavior might be changed by the main app. 
        subject.should_not include @intermediate_group_membership
      end
      it "should return current memberships, but not expired memberships" do
        subject.should include @membership
        @membership.destroy
        StatusGroupMembership.find_all_by_user( @user ).should_not include @membership
      end
    end

    describe ".find_all_by_user.now" do
      subject { StatusGroupMembership.find_all_by_user( @user ).now }
      it "should return current memberships, but not expired memberships" do
        subject.should include @membership
        @membership.destroy
        StatusGroupMembership.find_all_by_user( @user ).now.should_not include @membership
      end
    end

    describe ".find_all_by_user.now_and_in_the_past" do
      subject { StatusGroupMembership.find_all_by_user( @user ).now_and_in_the_past }
      it "should return current memberships and expired ones" do
        subject.should include @membership
        @membership.destroy
        StatusGroupMembership.find_all_by_user( @user ).now_and_in_the_past
          .should include @membership
      end
    end

    describe ".find_all_by_user.in_the_past" do
      subject { StatusGroupMembership.find_all_by_user( @user ).in_the_past }
      it "should return only expired memberships" do
        subject.should_not include @membership
        @membership.destroy
        StatusGroupMembership.find_all_by_user( @user ).in_the_past
          .should include @membership
      end
    end

  end
end
