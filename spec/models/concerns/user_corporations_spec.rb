require 'spec_helper'

describe UserCorporations do
  before do
    @user = create :user
    @group = create :group
    @corporation = create :corporation
  end

  describe "#corporation" do
    subject { @user.corporation }

    describe "for a fresh user" do
      it { should == nil }
    end

    describe "with the user being member of a corporation" do
      before do
        @group << @user
        @corporation << @user
      end
      it { should == @corporation }
    end
  end

  describe "#corporation_name" do
    subject { @user.corporation_name }

    describe "for a fresh user" do
      it { should == nil }
    end

    describe "with the user being member of a corporation" do
      before do
        @group << @user
        @corporation << @user
      end
      it { should == @corporation.name }
    end
  end

  describe "#corporation_name=" do
    subject { @user.corporation_name = "My Great Corporation, Inc." }

    describe "when the corporation does not exist" do
      specify { subject; @user.corporation_name.should == "My Great Corporation, Inc." }

      it "should create the corporation" do
        subject
        Corporation.pluck(:name).should include "My Great Corporation, Inc."
      end

      it "should assing the user to the corporation" do
        subject
        Corporation.where(name: "My Great Corporation, Inc.").first.members.should include @user
      end
    end

    describe "when the corporation exists" do
      before { @great_corporation = Corporation.create name: "My Great Corporation, Inc." }

      specify { subject; @user.corporation_name.should == "My Great Corporation, Inc." }

      it "should assign the user to the existing corporation" do
        subject
        @user.corporation.should == @great_corporation
      end
    end
  end

end