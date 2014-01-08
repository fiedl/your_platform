require 'spec_helper'

describe Corporation do

  describe "#is_first_corporation_this_user_has_joined?" do
    before do 
      @first_corporation = create( :corporation )
      @second_corporation = create( :corporation )
      @another_corporation = create( :corporation )
      @user = create( :user )

      @first_membership = UserGroupMembership.create( user: @user, group: @first_corporation )
      @first_membership.valid_from = 1.year.ago
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

      # status groups are leaf groups of corporations
      @status_group = create( :group )
      @intermediate_group = create( :group )
      @corporation.child_groups << @intermediate_group
      @intermediate_group.child_groups << @status_group

      @another_group = create( :group )
    end
    subject { @corporation.status_groups }
    
    it "should include the status groups, i.e. the leaf groups of the corporation" do
      subject.should include @status_group
    end
    it "should not include the non-status groups, i.e. the descendant_grous of the corporation that are no leafs" do
      subject.should_not include @intermediate_group
    end
    it "should not include unrelated groups" do
      subject.should_not include @another_group
    end
    describe "after calling admins" do
      before do
        @admins_parent = @status_group.admins_parent
        @officers_parent = @status_group.officers_parent
      end
      it "should still return the correct status groups" do
        subject.should include @status_group
      end
      it "should not return the officers parent groups" do
        subject.should_not include @officers_parent
      end
      it "should return the admins parent groups such that being admin is considered a status" do
        subject.should include @admins_parent
      end
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
