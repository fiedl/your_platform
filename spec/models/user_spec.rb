# -*- coding: utf-8 -*-
require 'spec_helper'

describe User do
  before do
    @user = User.new( first_name: "Max", last_name: "Mustermann", alias: "m.mustermann",
                      email: "max.mustermann@example.com", create_account: true )
  end

  subject { @user }

  it { should respond_to( :first_name ) }
  it { should respond_to( :last_name ) }
  it { should respond_to( :name ) }
  it { should respond_to( :alias ) }
  it { should respond_to( :email ) }
  it { should respond_to( :create_account ) }
  it { should respond_to( :groups ) }

  it { should be_valid }

  describe "#memberships" do
    it "should return all UserGroupMemberships of the user" do
      @user.memberships.collect { |membership| membership.dag_link.id }
        .should == UserGroupMembership.find_all_by_user( @user ).collect { |membership| membership.dag_link.id }
    end
    describe "( with_deleted: true )" do
      it "should return all UserGroupMemberships of the user, including the deleted ones" do
        @user.memberships( with_deleted: true ).collect { |membership| membership.dag_link.id }
          .should == UserGroupMembership.find_all_by_user( @user, with_deleted: true )
          .collect { |membership| membership.dag_link.id }
      end
    end
  end
  
end
