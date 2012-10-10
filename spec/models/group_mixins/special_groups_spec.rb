require 'spec_helper'

describe GroupMixins::SpecialGroups do 

  describe "erstbandphilister_parent_group" do

    before do

      # scenario: a user is philister in two corporations.
      # He has joined corporation_a in 1960 and corporation_b in 1962.
      # The older membership defines in which corporation he is erstbandphilister.

      @some_group = create( :group )

      @corporation_a = create( :wah_group )
      @philisterschaft_a = @corporation_a.philisterschaft
      @philister_a = @philisterschaft_a.child_groups.create( name: "Philister" )
      @erstbandphilister_a = @philisterschaft_a.create_erstbandphilister_parent_group

      @corporation_b = create( :wah_group )
      @philisterschaft_b = @corporation_b.philisterschaft
      @philister_b = @philisterschaft_b.child_groups.create( name: "Philister" )
      @erstbandphilister_b = @philisterschaft_b.create_erstbandphilister_parent_group

      @corporation_c = create( :wah_group )
      @philisterschaft_c = @corporation_c.philisterschaft

      @user = create( :user )
      @user.parent_groups << @philister_a
      @user.parent_groups << @philister_b
      
      @membership_a = UserGroupMembership.find_by_user_and_group( @user, @philister_a )
      @membership_a.created_at = "1960-01-01"; @membership_a.save
      @membership_b = UserGroupMembership.find_by_user_and_group( @user, @philister_b )
      @membership_b.created_at = "1962-01-01"; @membership_b.save

    end


    # Finder and Creator Methods
    # ------------------------------------------------------------------------------------------

    describe "#is_erstbandphilister_parent_group?" do
      context "for an erstbandphilister_parent_group" do
        subject { @erstbandphilister_a.is_erstbandphilister_parent_group? }
        it { should == true }
      end
      context "for a non-erstband_philister_parent_group" do
        subject { @philisterschaft_a.is_erstbandphilister_parent_group? }
        it { should == false }
      end
    end

    describe "#find_erstbandphilister_parent_group" do
      context "for a philisterschaft group" do
        context "if present" do
          subject { @philisterschaft_a.find_erstbandphilister_parent_group }
          it { should == @erstbandphilister_a }
        end
        context "if absent" do
          subject { @philisterschaft_c.find_erstbandphilister_parent_group }
          it { should == nil }
        end
      end
      context "for a non-philisterschaft group" do
        subject { @corporation_a.find_erstbandphilister_parent_group }
        it { should == nil }
      end
    end

    describe "#create_erstbandphilister_parent_group" do
      context "for a philisterschaft group" do
        context "if present" do
          it "should raise an error" do
            expect { @philisterschaft_a.create_erstbandphilister_parent_group }.to raise_error
          end
        end
        context "if absent" do
          subject { @philisterschaft_c.create_erstbandphilister_parent_group }
          it "should return the new erstbandphilister_parent_group" do
            subject.is_erstbandphilister_parent_group?.should be_true
            subject.parent_groups.first.should == @philisterschaft_c
          end
        end
      end
      context "for a non-philisterschaft group" do
        it "should raise an error" do
          expect { @some_group.create_erstbandphilister_parent_group }.to raise_error
        end
      end
    end

    describe "#erstbandphilister" do
      it "should be the same as #find_erstbandphilister_parent_group" do
        @philisterschaft_a.erstbandphilister.should == 
          @philisterschaft_a.find_erstbandphilister_parent_group
      end
    end

    describe "#erstbandphilister!" do
      context "if present" do
        it "should return the present group" do
          @philisterschaft_a.erstbandphilister!.should == 
            @philisterschaft_a.find_erstbandphilister_parent_group
        end
      end
      context "if absent" do
        it "should create the group" do
          @philisterschaft_c.erstbandphilister.should == nil
          erstbandphilister_c = @philisterschaft_c.erstbandphilister!
          erstbandphilister_c.is_erstbandphilister_parent_group?.should be_true
          erstbandphilister_c.should == @philisterschaft_c.find_erstbandphilister_parent_group
        end
      end
    end

    describe ".create_erstbandphilister_parent_groups" do
      subject { Group.create_erstbandphilister_parent_groups }
      it "should not raise an error, e.g. when trying to overwrite a group" do
        expect { subject }.to_not raise_error
      end
      it "should leave the present groups alone" do
        subject
        @philisterschaft_a.find_erstbandphilister_parent_group.should == @erstbandphilister_a
      end
      it "should create the absent groups" do
        subject
        @philisterschaft_c.find_erstbandphilister_parent_group.should_not == nil
        @philisterschaft_c.find_erstbandphilister_parent_group.is_erstbandphilister_parent_group?.should be_true
      end
    end


    # Redefined User Association Methods
    # ------------------------------------------------------------------------------------------

    describe "#users" do
      it "should return the child users" do
        UserGroupMembership.find_by_user_and_group( @user, @philisterschaft_a ).created_at.should <
          UserGroupMembership.find_by_user_and_group( @user, @philisterschaft_b ).created_at
        @erstbandphilister_a.users.should include( @user )
        @erstbandphilister_b.users.should_not include( @user )
        # because @user is erstbandphilister of @corporation_a but not of @corporation_b
        # (see 'scenario' comment in the before block.)
      end
    end

    describe "#child_users" do
      it "should be the same as #users" do
        @erstbandphilister_a.child_users.should == @erstbandphilister_a.users
      end
    end

    describe "#descendant_users" do
      it "should be the same as #users" do
        @erstbandphilister_a.descendant_users.should == @erstbandphilister_a.users
      end
    end

  end
end
