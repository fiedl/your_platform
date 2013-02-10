require 'spec_helper'

describe StatusGroupMembership do

  # Alias Methods for Delegated Methods
  # ==========================================================================================

  describe "#promoted_by_workflow" do
    before do
      @workflow = create( :workflow )
      @membership = create( :status_group_membership )
    end
    subject { @membership.promoted_by_workflow }
    describe "if one has been assigned" do
      before do
        @membership.promoted_by_workflow = @workflow
      end
      it "should return the workflow that has been associated" do
        subject.should == @workflow
      end
      it "should persist" do
        @membership.save
        @reloaded_membership = StatusGroupMembership.find( @membership.id )
        @reloaded_membership.promoted_by_workflow.should == @workflow
        @reloaded_membership = StatusGroupMembership
          .find_by_user_and_group( @membership.user, @membership.group )
        @reloaded_membership.promoted_by_workflow.should == @workflow
      end
      it "should be an alias of #workflow" do
        subject.should == @membership.workflow
      end
    end
    describe "if none has been assigned" do
      it { should == nil }
    end
  end

  describe "#promoted_on_event" do
    before do
      @event = create( :event )
      @membership = create( :status_group_membership )
    end
    subject { @membership.promoted_on_event }
    describe "if one has been assigned" do
      before { @membership.promoted_on_event = @event }
      it { should == @event }
      it "should persist" do
        @membership.save
        @reloaded_membership = StatusGroupMembership.find( @membership.id )
        @reloaded_membership.promoted_on_event.should == @event
        @reloaded_membership = StatusGroupMembership
          .find_by_user_and_group( @membership.user, @membership.group )
        @reloaded_membership.promoted_on_event.should == @event
      end
      it "should be an alias of #event" do
        subject.should == @membership.event
      end
    end
    describe "if none has been assigned" do
      it { should == nil }
    end
  end

  describe "#event_by_name" do
    before do
      @membership = create( :status_group_membership )
    end
    subject { @membership.event_by_name }
    describe "for existing event" do
      before do
        @event = create( :event )
        @membership.event = @event
      end
      it { should == @event.name }
    end
    describe "if no event is assigned" do
      it { should == nil }
    end
  end
  describe "#event_by_name=" do
    before do
      @membership = create( :status_group_membership )
    end
    describe "for an existing event" do
      before { @event = create( :event ) }
      subject { @membership.event_by_name = @event.name }
      it "should assign the event" do
        @membership.event.should == nil
        subject
        @membership.event.should == @event
      end
    end
    describe "for a new event" do
      subject { @membership.event_by_name = "A New Event" }
      it "should create the event" do
        @membership.event.should == nil
        subject
        @membership.event.name.should == "A New Event"
      end
      it "should mark the membership as changed" do
        @membership.status_group_membership_info.changed?.should be_true
        @membership.changed?.should be_true
      end
      it "should persist" do
        @membership.save
        @reloaded_membership = StatusGroupMembership.find( @membership.id )
        @reloaded_membership.event.should == @membership.event
        @reloaded_membership.event.name.should == "A New Event"
      end
      describe "for the membership having a corporation" do
        before do
          @corporation = create( :corporation )
          @corporation.child_groups << @membership.group
        end
        it "should association the corporation with the new event" do
          subject
          @membership.event.group.should == @corporation
        end
      end
    end
  end
    


  # Finder Methods
  # ==========================================================================================
  
  class SomeCorporationDerivative < Corporation
    # This is just a dummy. The main app could invent a class inherited from Corporation.
    # Some methods need to work with them as well as with the original Corporation class.
  end

  describe "Finder Methods: " do
    before do
      @corporation = create( :corporation )
      @intermediate_group = create( :group, name: "Not a Status Group" )
      @status_group = create( :group, name: "Status Group" )

      @intermediate_group.parent_groups << @corporation
      @status_group.parent_groups << @intermediate_group
      @user = create( :user )
      @status_group.assign_user @user

      @membership = UserGroupMembership.find_by_user_and_group( @user, @status_group )
        .becomes( StatusGroupMembership )
      @intermediate_group_membership = UserGroupMembership
        .find_by_user_and_group( @user, @intermediate_group ).becomes StatusGroupMembership
    end

    describe ".find_all_by_corporation" do
      subject { StatusGroupMembership.find_all_by_corporation( @corporation ) }
      it "should be chainable, i.e. return an ActiveRecord::Relation object" do
        subject.should be_kind_of ActiveRecord::Relation
      end
      it "should return the membership of the descendant_users in their status groups" do
        subject.should include @membership
      end
      it "should work for corporation derivatives as well" do
        @corporation_derivative = @corporation.becomes SomeCorporationDerivative
        expect { StatusGroupMembership.find_all_by_corporation( @corporation_derivative ) }
          .not_to raise_error
      end
      it "should not return memberships in intermediate groups" do
        # this behavior might be changed by the main app. 
        subject.should_not include @intermediate_group_membership
      end
    end

    describe ".find_all_by_user" do
      subject { StatusGroupMembership.find_all_by_user( @user ) }
      it "should be chainable, i.e. return an ActiveRecord::Relation object" do
        subject.should be_kind_of ActiveRecord::Relation
      end
      it "should return the memberships of the user in his status groups" do
        subject.should include @membership
      end
      it "should not list memberships of the user in non-status groups" do
        @non_status_membership = UserGroupMembership
          .find_by_user_and_group( @user, @corporation )
        subject.should_not include @non_status_membership
      end
      it "should not return memberships in intermediate groups" do
        # this behavior might be changed by the main app. 
        subject.should_not include @intermediate_group_membership
      end
      it "should return current memberships, but not expired memberships" do
        subject.should include @membership
        @membership.destroy
        StatusGroupMembership.find_all_by_user( @user ).should_not include @membership
      end
    end

    describe ".find_all_by_user.now" do
      subject { StatusGroupMembership.find_all_by_user( @user ).now }
      it "should return current memberships, but not expired memberships" do
        subject.should include @membership
        @membership.destroy
        StatusGroupMembership.find_all_by_user( @user ).now.should_not include @membership
      end
    end

    describe ".find_all_by_user.now_and_in_the_past" do
      subject { StatusGroupMembership.find_all_by_user( @user ).now_and_in_the_past }
      it "should return current memberships and expired ones" do
        subject.should include @membership
        @membership.destroy
        StatusGroupMembership.find_all_by_user( @user ).now_and_in_the_past
          .should include @membership
      end
    end

    describe ".find_all_by_user.in_the_past" do
      subject { StatusGroupMembership.find_all_by_user( @user ).in_the_past }
      it "should return only expired memberships" do
        subject.should_not include @membership
        @membership.destroy
        StatusGroupMembership.find_all_by_user( @user ).in_the_past
          .should include @membership
      end
    end

    describe ".find_all_by_user_and_corporation" do
      subject { StatusGroupMembership.find_all_by_user_and_corporation( @user, @corporation ) }
      it "should return the memberships of the user in the status groups of the corporation" do
        subject.should include @membership
      end
    end

  end
end
