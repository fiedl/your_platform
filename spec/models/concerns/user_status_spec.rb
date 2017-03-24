require 'spec_helper'

describe UserStatus do

  before do
    @user = create :user
  end

  describe "#status_groups" do
    before do
      @corporation = create(:corporation_with_status_groups)
      @status_group = @corporation.status_groups.first
      @status_group.assign_user @user
      @another_group = create(:group)
      @another_group.assign_user @user
    end
    subject { @user.reload.status_groups }

    it "should include the status groups of the user" do
      subject.should include @status_group
    end
    it "should not include the non-status groups of the user" do
      subject.should_not include @another_group
    end
  end

  describe "#current_status_membership_in(corporation)" do
    before do
      @corporation = create(:corporation_with_status_groups)
      @status_group = @corporation.status_groups.first
      @status_group.assign_user @user
      @status_membership = Memberships::Status.find_by_user_and_group(@user, @status_group)
    end
    subject { @user.reload.current_status_membership_in(@corporation) }

    it "should return the correct membership" do
      subject.should == @status_membership
    end
  end

end