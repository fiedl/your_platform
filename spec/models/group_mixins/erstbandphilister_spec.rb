require 'spec_helper'

describe GroupMixins::Erstbandphilister do

  describe "erstbandphilister_parent_group" do

    before do

      # scenario: a user is philister in two corporations.
      # He has joined corporation_a in 1960 and corporation_b in 1962.
      # The older membership defines in which corporation he is erstbandphilister.

      @some_group = create( :group )

      @corporation_a = create( :wah_group )
      @philisterschaft_a = @corporation_a.philisterschaft
      
      @philister_a = @corporation_a.status_group("Philister")
      @erstbandphilister_a = @philisterschaft_a.create_erstbandphilister_parent_group

      @corporation_b = create( :wah_group )
      @philisterschaft_b = @corporation_b.philisterschaft
      @philister_b = @corporation_b.status_group("Philister")
      @erstbandphilister_b = @philisterschaft_b.create_erstbandphilister_parent_group

      @corporation_c = create( :wah_group )
      @philisterschaft_c = @corporation_c.philisterschaft

      @user = create( :user )
      @membership_a = @philister_a.assign_user @user, at: "1960-01-01".to_datetime
      @membership_b = @philister_b.assign_user @user, at: "1962-01-01".to_datetime
      
      @user.reload
    end
    
    specify "prelims" do
      @membership_a.reload.valid_from.year.should == 1960
      @membership_b.reload.valid_from.year.should == 1962
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

    describe "#members" do
      specify "presumption: @user is erstbandphilister of A but not of B" do
        @user.reload
        UserGroupMembership.find_by_user_and_group( @user, @philisterschaft_a ).valid_from.should <
          UserGroupMembership.find_by_user_and_group( @user, @philisterschaft_b ).valid_from
        @erstbandphilister_a.reload.members.should include @user
        @erstbandphilister_b.reload.members.should_not include @user
      end
      subject { @erstbandphilister_a.members }
      it "should return the child users" do
        subject.should include @user
      end
      it { subject.should be_kind_of ActiveRecord::Relation }
      it "should support pagination" do
        subject.should respond_to :page
      end
    end

    describe "#direct_members" do
      it "should be the same as #members" do
        @erstbandphilister_a.direct_members.should == @erstbandphilister_a.members
      end
    end

  end
end
