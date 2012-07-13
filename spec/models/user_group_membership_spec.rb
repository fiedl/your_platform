require 'spec_helper'

describe UserGroupMembership do

  before do
    @group = Group.create( name: "Some Group" )
    @user = User.create( first_name: "John", last_name: "Doe", :alias => "j.doe" )
  end

  it "should allow to create example group and user" do
    @user.should_not == nil
    @group.should_not == nil
  end

  def create_membership 
    UserGroupMembership.create( user: @user, group: @group )
  end

  describe ".create" do

    it "should create a link between parent and child" do
      create_membership

      @user.parents.include?( @group ).should be_true
    end

    it "should raise an error if argument is missing" do
      expect { UserGroupMembership.create( user: @user ) }.should raise_error RuntimeError
      expect { UserGroupMembership.create( group: @group ) }.should raise_error RuntimeError
    end
    
  end

  describe "#exists?" do
    it "should return true if membership has been created" do
      membership = create_membership
      membership.exists?.should be_true
    end
    it "should return false if membership has not been created" do
      # The following call does not create a membership, it just represents a hypothetical membership.
      membership = UserGroupMembership.new( user: @user, group: @group )
      membership.exists?.should be_false
    end
    it "should return true if membership has been re-created" do
      membership = create_membership
      membership.destroy
      sleep 1.5 # to make sure that the ordering by :created_at is properly done
      recreated_membership = create_membership
      recreated_membership.exists?.should be_true
    end
  end

  describe "#existed?" do
    it "should return true if the membership existed in the past" do
      membership = create_membership
      membership.destroy
      membership.existed?.should be_true
    end
    it "should return false if the membership never existed" do
      UserGroupMembership.new( user: @user, group: @group).existed?.should be_false
    end
    it "should return false if the membership did not exist in the past" do
      membership = create_membership
      membership.existed?.should be_false
    end
    it "should return true if the membership did exist in the past, but also exists in the present" do
      membership = create_membership
      membership.destroy
      recreated_membership = create_membership
      recreated_membership.existed?.should be_true
    end
  end

  describe "#deleted?" do
    it "should be false if the membership exists" do
      membership = create_membership
      membership.deleted?.should be_false
    end
    it "should be true if the membership has been deleted" do
      membership = create_membership
      membership.destroy
      UserGroupMembership.new( user: @user, group: @group ).deleted?.should be_true
    end
  end

  describe "#created_at" do
    it "should be the time of creation" do
      time_before_creation = Time.current
      membership = create_membership
      membership.created_at.to_i.should >= time_before_creation.to_i
      membership.created_at.to_i.should <= Time.current.to_i
    end
  end

  describe "#created_at=" do
    it "should set the time of creation, i.e. the beginning of the membership" do
      membership = create_membership
      membership.created_at = 1.hour.ago
      membership.save
      membership.created_at.to_i.should == 1.hour.ago.to_i
      membership.at_time( 30.minutes.ago ).exists?.should be_true
      membership.at_time( Time.current + 30.minutes ).exists?.should be_true
      membership.destroy
      membership.at_time( Time.current + 30.minutes ).exists?.should be_false
    end
  end

  describe "#deleted_at" do
    it "should be nil before deletion" do
      membership = create_membership
      membership.deleted_at.should == nil
    end
    it "should be the time of deletion" do
      membership = create_membership
      time_before_deletion = Time.current
      membership.destroy
      membership.deleted_at.to_i.should >= time_before_deletion.to_i
      membership.deleted_at.to_i.should <= Time.current.to_i
    end
  end

  describe "#deleted_at=" do
    it "should set the time of deletion, i.e. the termination of the membership" do
      membership = create_membership
      membership.destroy
      membership.deleted_at = Time.current + 1.hour
      membership.save
      membership.at_time( Time.current + 30.minutes ).exists?.should be_true
      membership.at_time( Time.current + 2.hours ).exists?.should be_false
    end
  end

  describe "#dag_links" do
    it "should return an array of dag links that represent the membership in ascending order by created_at" do
      membership = create_membership
      link1 = @user.links_as_child.first
      membership.destroy
      membership = create_membership
      link2 = @user.links_as_child.first
      membership.dag_links.should == [ link1, link2 ]
    end
  end

  describe "#dag_link" do
    it "should always refer to the last created link" do
      membership = create_membership
      3.times do
        membership.dag_link.should == membership.dag_links.last

        sleep 1.5 # to make sure that the ordering by :created_at works
        membership.destroy
        membership = create_membership
      end
    end
  end

  describe "#== ( other_membership ), i.e. euality relation, " do
    it "should return true if the two memberships refer to the same dag_link, i.e. represent the same membership" do
      membership = create_membership
      same_membership = UserGroupMembership.new( user: @user, group: @group )
      membership.should == same_membership
    end
  end

  describe "after creation" do

    subject { @membership }
    
    before do
      @membership = create_membership
    end

    describe "#destroy" do
      it "should destroy a membership" do
        @membership.destroy

        UserGroupMembership.new( user: @user, group: @group ).exists?.should be_false
        @membership.exists?.should be_false
      end
    end
    
    describe "#user" do
      its( :user ) { should == @user }
    end
    
    describe "#group" do
      its( :group ) { should == @group }
    end

  end

  describe "finder method" do
    
    describe ".find_by_user_and_group" do
      it "should find the right membership" do
        membership = create_membership
        UserGroupMembership.find_by_user_and_group( @user, @group ).dag_link.id.should == membership.dag_link.id
      end
    end

    describe ".find_all_by_user" do
      it "should find the right memberships" do
        membership = create_membership
        UserGroupMembership.find_all_by_user( @user ).collect { |membership| membership.dag_link.id }
          .include?( membership.dag_link.id ).should be_true
      end
    end

    describe ".find_all_by_group" do
      it "should find the right memberships" do
        membership = create_membership
        UserGroupMembership.find_all_by_group( @group ).collect { |membership| membership.dag_link.id }
          .include?( membership.dag_link.id ).should be_true
      end
    end
  end

  describe "indirect membership" do
    
    before do
      @sub_group = Group.create( name: "Sub Group" )
      @sub_group.parent_groups << @group
      @user.parent_groups << @sub_group
      @membership = UserGroupMembership.find_by_user_and_group( @user, @sub_group )
      @indirect_membership = UserGroupMembership.find_by_user_and_group( @user, @group )
    end

    subject { @indirect_membership }

    it "should have the same date of creation as the direct membership" do
      @indirect_membership.created_at.should == @membership.created_at
    end

    it "should have the same date of deletion as the direct membership" do
      @indirect_membership.deleted_at.should == @membership.deleted_at 
    end

    it "should also effect the direct membership on change of date of creation" do
      new_time = 1.hour.ago
      @membership.created_at = new_time
      @membership.save
      @indirect_membership.created_at.to_i.should == new_time.to_i
    end

    it "should also effect the direct membership on change of date of deletion" do
      new_time = Time.current + 1.hour
      @membership.destroy
      @membership.deleted_at = new_time
      @membership.save
      @indirect_membership.deleted_at.to_i.should == new_time.to_i
    end

    it "should be effected by the direct membership on change of date of creation" do
      new_time = 1.hour.ago
      @indirect_membership.created_at = new_time
      @indirect_membership.save
      @membership.created_at.to_i.should == new_time.to_i
    end

    it "should not be destroyable" do
      expect { @indirect_membership.destroy }.should raise_error RuntimeError
    end

    it "should be effected by the direct membership on change of date of deletion" do
      new_time = Time.current + 1.hour
      @membership.destroy # need to destroy the *direct* membership, ...
      @indirect_membership.deleted_at = new_time # but can change the time of the *indirect*.
      @indirect_membership.save
      @membership.deleted_at.to_i.should == new_time.to_i
    end

    describe "#devisor_dag_link" do
      it "should return the direct membership corresponding to self, if self is an indirect membership" do
        @indirect_membership.devisor_membership.should == @membership
      end
      it "should return self, if self is a direct membership itself" do
        @membership.devisor_membership.should == @membership
      end
    end


  end
    
end
