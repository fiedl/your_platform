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
  
end

