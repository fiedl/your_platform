require 'spec_helper'

describe StatusMembershipFinders do

  #   @corporation
  #        |------- @intermediate_group
  #                         |------------ @status_group
  #                         |                  |--------- @user
  #                         |
  #                         |------------ @second_status_group
  #
  before do
    @corporation = create(:corporation)
    @intermediate_group = create(:group, name: "Not a Status Group")
    @status_group = create(:group, name: "Status Group", type: "StatusGroup").becomes(StatusGroup)

    @intermediate_group.parent_groups << @corporation
    @status_group.parent_groups << @intermediate_group
    @user = create(:user)
    @status_group.assign_user @user

    @membership = Membership.find_by_user_and_group(@user, @status_group)
    @intermediate_group_membership = Membership.find_by_user_and_group(@user, @intermediate_group)

    @second_status_group = @intermediate_group.child_groups
        .create(name: "Second Status Group", type: "StatusGroup").becomes(StatusGroup)

    @other_corporation = create(:corporation_with_status_groups)
    @membership_in_other_corporation = @other_corporation.status_groups.first.assign_user(@user)

    @other_user = create(:user)
    @membership_of_other_user = @status_group.assign_user(@other_user)
  end

  specify "prelims" do
    @membership.should be_kind_of Memberships::Status
  end

  describe ".find_all_by_corporation" do
    subject { Memberships::Status.find_all_by_corporation(@corporation) }
    it "should be chainable, i.e. return an ActiveRecord::Relation object" do
      subject.should be_kind_of ActiveRecord::Relation
    end
    its(:first) { should be_kind_of Memberships::Status }
    it "should return the membership of the descendant_users in their status groups" do
      subject.should include @membership
    end
    it "should not return memberships in intermediate groups" do
      # this behavior might be changed by the main app.
      subject.should_not include @intermediate_group_membership
    end
  end

  describe ".find_all_by_user" do
    subject { Memberships::Status.find_all_by_user(@user) }
    it "should be chainable, i.e. return an ActiveRecord::Relation object" do
      subject.should be_kind_of ActiveRecord::Relation
    end
    its(:first) { should be_kind_of Memberships::Status }
    it "should return the memberships of the user in his status groups" do
      subject.should include @membership
    end
    it "should not list memberships of the user in non-status groups" do
      @non_status_membership = Membership.find_by_user_and_group(@user, @corporation)
      subject.should_not include @non_status_membership
    end
    it "should not return memberships in intermediate groups" do
      # this behavior might be changed by the main app.
      subject.should_not include @intermediate_group_membership
    end
    it "should return current memberships, but not expired memberships" do
      subject.should include @membership
      @membership.invalidate at: 2.minutes.ago
      Memberships::Status.find_all_by_user(@user).should_not include @membership
    end
  end

  describe ".find_all_by_user" do
    describe ".now" do
      subject { Memberships::Status.find_all_by_user(@user).now }
      it "should return current memberships, but not expired memberships" do
        subject.should include @membership
        @membership.invalidate at: 2.minutes.ago
        Memberships::Status.find_all_by_user(@user).now.should_not include @membership
      end
    end

    describe ".now_and_in_the_past" do
      subject { Memberships::Status.find_all_by_user(@user).now_and_in_the_past }
      it "should return current memberships and expired ones" do
        subject.should include @membership
        @membership.invalidate at: 2.minutes.ago
        Memberships::Status.find_all_by_user(@user).now_and_in_the_past
            .should include @membership
      end
    end

    describe ".in_the_past" do
      subject { Memberships::Status.find_all_by_user(@user).in_the_past }
      it "should return only expired memberships" do
        subject.should_not include @membership
        @membership.invalidate at: 2.minutes.ago
        Memberships::Status.find_all_by_user(@user).in_the_past
            .should include @membership
      end
    end
  end

  describe ".find_all_by_user_and_corporation" do
    subject { Memberships::Status.find_all_by_user_and_corporation(@user, @corporation) }
    it "should return the memberships of the user in the status groups of the corporation" do
      subject.should include @membership
    end
    it "should not return memberships in other corporations" do
      subject.should_not include @membership_in_other_corporation
    end
    it "should not return memberships of other users" do
      subject.should_not include @membership_of_other_user
    end
  end

  #   @corporation
  #        |------- @intermediate_group
  #                         |------------ @status_group
  #                         |                  |--------- (@user)
  #                         |
  #                         |------------ @second_status_group
  #                                            |--------- @user
  #
  describe ".find_all_by_user_and_corporation.now_and_in_the_past" do
    before do
      @membership.update_attributes valid_from: 1.year.ago
      @second_membership = @membership.move_to(@second_status_group, at: 20.days.ago)
    end
    subject { Memberships::Status.find_all_by_user_and_corporation(@user, @corporation).now_and_in_the_past }
    specify "prelims" do
      @user.should be_kind_of User
      @corporation.reload.should be_kind_of Corporation
      @corporation.descendants.should include @intermediate_group, @status_group, @second_status_group, @user
      @intermediate_group.reload.descendants.should include @status_group, @second_status_group, @user
      @status_group.reload.descendants.should include @user
      @second_status_group.reload.descendants.should include @user
      @corporation.members.should include @user
      @user.should be_member_of @corporation
      @membership.valid_to.to_date.should == 20.days.ago.to_date
      @second_membership.should be_kind_of Memberships::Status
    end
    it { should include @second_membership }
    it { should include @membership }
    it { should_not include @intermediate_group_membership }
  end


end