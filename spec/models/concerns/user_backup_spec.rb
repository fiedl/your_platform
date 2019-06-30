require 'spec_helper'

describe UserBackup do
  before do
    @user = create :user_with_account, :with_profile_fields, :with_date_of_birth, :with_address, :with_bank_account, :with_corporate_vita, email: "johnny@example.com"
    @email = @user.email
    @postal_address = @user.postal_address
    @alias = @user.alias
    @last_status_membership_valid_from = @user.status_memberships.last.valid_from
    @date_of_birth = @user.date_of_birth
  end

  describe "#backup_and_remove_profile" do
    subject { @user.backup_and_remove_profile(confirm: "yes") }

    it "should export the profile to a backup file" do
      @user.email.should be_present
      subject
      @user.latest_backup_file.should be_present
      File.read(@user.latest_backup_file).should include @email
    end

    it "should remove the user's profile fields" do
      @user.profile_fields.count.should > 0
      subject
      @user.reload.profile_fields.count.should == 0
    end

    it "should remove the user's account" do
      @user.account.should be_present
      subject
      @user.reload.account.should be_nil
    end

    it "should remove the user's email" do
      @user.email.should be_present
      subject
      @user.reload.email.should be_nil
    end

    it "should remove the user's alias" do
      @user.alias.should be_present
      subject
      @user.reload.alias.should be_nil
    end

    it "should remove the user's postal address" do
      @user.postal_address.should be_present
      subject
      @user.reload.postal_address.should be_nil
    end

    it "should keep the corporate vita" do
      @user.status_memberships.last.valid_from.should be_present
      subject
      @user.status_memberships.last.valid_from.should be_present
    end

    it "should remove the date of birth" do
      @user.date_of_birth.should be_present
      subject
      @user.date_of_birth.should be_nil
    end
  end

  describe "#restore_profile" do
    subject do
      @user.backup_and_remove_profile(confirm: "yes")
      @user.restore_profile
    end
    before { subject; @user.reload }

    it "should restore the email address" do
      @user.email.should == @email
    end

    it "should restore the postal address" do
      @user.postal_address.should == @postal_address
    end

    it "should restore the alias" do
      @user.alias.should == @alias
    end

    it "should not preserve the corporate vita" do
      @user.status_memberships.last.valid_from.should == @last_status_membership_valid_from
    end

    it "should restore the date of birth" do
      @user.date_of_birth.should == @date_of_birth
    end
  end
end