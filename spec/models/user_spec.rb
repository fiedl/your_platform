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
      @corporationE = create( :wah_group, :token => "E" )
      @membershipE = UserGroupMembership.create( user: @user, group: @corporationE.aktivitas )
      @membershipE.created_at = "2006-12-01"
      @membershipE.save

      @corporationH = create( :wah_group, :token => "H" )
      @membershipH = UserGroupMembership.create( user: @user, group: @corporationH.aktivitas )
      @membershipH.created_at = "2008-12-01"
      @membershipH.save
    end
    subject { @user.aktivitaetszahl }
    it "should return the composed aktivitaetszahl" do
      subject.should == "E06 H08"
    end
  end

  it "should fail for testing reasons" do
    @test = "1"
    @test.should == "2"
  end

end

