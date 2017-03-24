require 'spec_helper'

describe GroupEveryone do


  # Everyone Group
  # ==========================================================================================

  describe "everyone_group" do
    before do
      Group.destroy_all
      @everyone_group = Group.create_everyone_group
    end

    describe ".create_everyone_group" do
      it "should create the group 'everyone' and return it" do
        @everyone_group.ancestor_groups.count.should == 0
        @everyone_group.has_flag?( :everyone ).should == true
      end
    end

    describe ".find_everyone_group" do
      subject { Group.find_everyone_group }
      it "should return the everyone_group" do
        subject.should == @everyone_group
        subject.has_flag?( :everyone ).should == true
      end
    end
  end


  # Members
  # ==========================================================================================

  before do
    @user = create(:user)
    @group = create(:group)
    @everyone_group = Group.find_everyone_group
  end

  describe "#members" do
    subject { @everyone_group.members }
    it "should include users that are in no group at all" do
      subject.should include @user
    end
    it "should include users that are in any unrelated group" do
      @group.assign_user @user
      subject.should include @user
    end
  end

  describe "#direct_members" do
    subject { @everyone_group.direct_members }
    it "should include users that are in no group at all" do
      subject.should include @user
    end
    it "should include users that are in any unrelated group" do
      @group.assign_user @user
      subject.should include @user
    end
  end

end
