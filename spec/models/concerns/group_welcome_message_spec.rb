require 'spec_helper'

describe GroupWelcomeMessage do

  before do
    @user = create :user_with_account
    @corporation = create :corporation_with_status_groups
    @corporation.welcome_message = "Welcome to Corporation X!"
  end

  describe "#assign_user" do
    subject { @group.assign_user @user }

    describe "for direct memberships" do
      before { @group = @corporation }

      it "should add the welcome message as notification" do
        subject
        @user.notifications.last.text.should == "Welcome to Corporation X!"
        @user.notifications.count.should == 1
      end
    end

    describe "for indirect memberships" do
      before { @group = @corporation.status_groups.first }

      it "should add the welcome message as notification" do
        subject
        @user.notifications.last.text.should == "Welcome to Corporation X!"
        @user.notifications.count.should == 1
      end

      describe "when already being member of a super group" do
        before { @corporation.status_groups.last.assign_user @user, at: 1.year.ago }

        it "should not add the welcome message as new notification" do
          @user.notifications.last.text.should == "Welcome to Corporation X!"
          @user.notifications.count.should == 1
          subject
          @user.notifications.count.should == 1
        end
      end
    end
  end

  describe "Membership#move_to" do
    before { @membership = @corporation.status_groups.first.assign_user @user, at: 1.year.ago }
    subject { @membership.move_to @corporation.status_groups.last }

    specify "prelims" do
      subject
      @user.should be_member_of @corporation.status_groups.last
      @user.should_not be_member_of @corporation.status_groups.first
      @user.should be_member_of @corporation
    end
    it "should not add the welcome message as new notification" do
      @user.notifications.last.text.should == "Welcome to Corporation X!"
      @user.notifications.count.should == 1
      subject
      @user.notifications.count.should == 1
    end
  end

end