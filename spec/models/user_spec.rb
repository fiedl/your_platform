# -*- coding: utf-8 -*-
require 'spec_helper'

describe User do

  before do 
    @user = create( :user )
  end

  describe "#title" do
    before do
      @corporation = create( :wah_group )
      @user.parent_groups << @corporation.aktivitas
    end
    subject { @user.title }
    it "should return the user's name and his aktivitaetszahl" do
      @user.name.blank?.should be_false
      @user.aktivitaetszahl.blank?.should be_false
      subject.should == @user.name + "  " + @user.aktivitaetszahl
    end
  end

  describe "#bv" do
    before do
      @bv = create( :bv_group )
      @bv.child_users << @user
    end
    subject { @user.bv }
    it "should return the user's bv" do
      subject.should == @bv
    end
  end

  describe "aktivitaetszahl" do
    before do
      @corporationE = create( :corporation_with_status_groups, :token => "E" )
      @corporationH = create( :corporation_with_status_groups, :token => "H" )

      @first_membership_E = StatusGroupMembership.create( user: @user, group: @corporationE.status_groups.first )
      @first_membership_E.update_attributes( created_at: "2006-12-01".to_datetime )
      @first_membership_H = StatusGroupMembership.create( user: @user, group: @corporationH.status_groups.first )
      @first_membership_H.update_attributes( created_at: "2008-12-01".to_datetime )
      @first_membership_E.destroy
      @second_membership_E = StatusGroupMembership.create( user: @user, group: @corporationE.status_groups.last )
      @second_membership_E.update_attributes( created_at: "2013-12-01".to_datetime )
    end
    subject { @user.aktivitaetszahl }
    it "should return the composed aktivitaetszahl" do
      subject.should == "E06 H08"
    end
    it "should include only the right years (bug fix)" do
      subject.should_not == "H08 E13"
    end
    it "should not use the wrong order (bug fix)" do
      subject.should_not == "H08 E06"
    end
  end

  describe "#fill_in_template_profile_information" do

    before do
      @wingolfsblaetter_page = Page.create(title: "Wingolfsblätter")
      @abonnenten_group = @wingolfsblaetter_page.child_groups.create(name: "Abonnenten")
    end

    subject { @user.fill_in_template_profile_information }

    it "should not change the name of the user" do
      expect { subject }.to_not change { @user.name } 
    end
    it "should fill in certain empty profile fields" do
      subject
      @user.profile_fields.where(label: :personal_title).count.should == 1
      @user.profile_fields.where(label: :cognomen).count.should == 1
      @user.profile_fields.where(label: :home_address).count.should == 1
      @user.profile_fields.where(label: :work_or_study_address).count.should == 1
      @user.profile_fields.where(label: :phone).count.should == 1
      @user.profile_fields.where(label: :mobile).count.should == 1
      @user.profile_fields.where(label: :fax).count.should == 1
      @user.profile_fields.where(label: :homepage).count.should == 1
      @user.profile_fields.where(label: :academic_degree).count.should == 1
      @user.profile_fields.where(label: :professional_category).count.should == 1
      @user.profile_fields.where(label: :occupational_area).count.should == 1
      @user.profile_fields.where(label: :employment_status).count.should == 1
      @user.profile_fields.where(label: :bank_account).count.should == 1
      @user.profile_fields.where(label: :study).count.should == 1
    end
    it "should set the wingolfsblaetter_abo to true" do
      subject
      @user.wingolfsblaetter_abo.should == true
    end
  end

  describe "#wingolfsblaetter_abo" do

    before do
      @wingolfsblaetter_page = Page.create(title: "Wingolfsblätter")
      @abonnenten_group = @wingolfsblaetter_page.child_groups.create(name: "Abonnenten")
    end

    subject { @user.wingolfsblaetter_abo }

    describe "for the user being member of the @abonnenten_group" do
      before { @abonnenten_group.assign_user @user }
      it { should be_true }
    end
    describe "for the user not being member of the @abonnenten_group" do
      it { should be_false }
    end

    describe "#wingolfsblaetter_abo = true" do
      subject { @user.wingolfsblaetter_abo = true }
      it "should assign the user to the @abonnenten_group" do
        @abonnenten_group.child_users.should_not include @user
        subject
        Group.find(@abonnenten_group.id).child_users.should include @user
      end
    end
    describe "#wingolfsblaetter_abo = false" do
      before { @abonnenten_group.assign_user @user }
      subject { @user.wingolfsblaetter_abo = false }
      it "should un-assign the user to the @abonnenten_group" do
        subject
        Group.find(@abonnenten_group.id).child_users.should_not include @user
      end
    end

  end
  
end

