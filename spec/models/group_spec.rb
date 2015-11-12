require 'spec_helper'

describe Group do

  # General Properties
  # ==========================================================================================

  describe "(Basic Properties)" do

    before { @group = create( :group ) }
    subject { @group }

    it { should respond_to( :name ) }
    it { should respond_to( :name= ) }
    it { should respond_to( :token ) }
    it { should respond_to( :token= ) }
    it { should respond_to( :internal_token ) }
    it { should respond_to( :internal_token= ) }
    it { should respond_to( :extensive_name ) }
    it { should respond_to( :extensive_name= ) }

    describe "#title" do
      it "should be the same as the group's name" do
        @group.name = "Group Name"
        @group.title.should == "Group Name"
      end
    end

    describe "#name" do
      subject { @group.name }
      describe "for a translation of the name exists" do
        before { @group.name = "admins" }
        it "should return the translated name" do
          I18n.t(:admins).should_not == "admins"
          subject.should == I18n.t(:admins)
        end
      end
      describe "for no translation of the name exists" do
        before { @group.name = "asdjkl" }
        it "should return the name itself" do
          subject.should == "asdjkl"
        end
      end
    end

  end


  # Associated Objects
  # ==========================================================================================
  
  # Workflows
  # ------------------------------------------------------------------------------------------

  describe "(Workflows)" do
    # 
    # @group
    #   |---- @subgroup --- @subworkflow
    #   |---- @workflow
    #
    before do
      @group = create( :group )
      @subgroup = create( :group )
      @subgroup.parent_groups << @group
      
      @workflow = create( :workflow )
      @workflow.parent_groups << @group
      @subworkflow = create( :workflow )
      @subworkflow.parent_groups << @subgroup

      @group.reload
      @workflow.reload
    end
    subject { @group }

    describe "#descendant_workflows" do
      it "should return the workflows of the group and its subgroups" do
        @group.descendant_workflows.should include( @workflow, @subworkflow )
        @workflow.ancestor_groups.should include( @group )
      end
    end

    describe "#child_workflows" do
      it "should return only the workflows of the groups, not of the subgroups" do
        @group.child_workflows.should include( @workflow )
        @group.child_workflows.should_not include( @subworkflow )
        @workflow.ancestor_groups.should include( @group )
        @subworkflow.ancestor_groups.should include( @group, @subgroup )
      end
    end
  end


  # Events
  # ------------------------------------------------------------------------------------------

  describe "(Events)" do
    before do 
      @group = create( :group )
      @subgroup = @group.child_groups.create
      @upcoming_events = [ @group.events.create( start_at: 5.hours.from_now ), 
                           @subgroup.events.create( start_at: 5.hours.from_now ) ]
      @recent_events = [ @group.events.create( start_at: 2.days.ago ) ]
      @unrelated_events = [ create( :event ) ]
    end

    describe "#upcoming_events" do
      subject { @group.upcoming_events }
      it { should include *@upcoming_events }
      it { should_not include *@recent_events }
      it { should_not include *@unrelated_events }
    end

    describe "#events" do
      subject { @group.events }
      it { should include *@upcoming_events }
      it { should include *@recent_events }
      it { should_not include *@unrelated_events }
    end
  end


  # Groups
  # ------------------------------------------------------------------------------------------

  describe "(Groups)" do
    describe "#descendant_groups_by_name" do
      before do
        @name_match = "Group Name"
        @group = create( :group )
        @group1 = create( :group, :name => @name_match ); @group1.parent_groups << @group
        @group2 = create( :group, :name => "Other #{@name_match}" ); @group2.parent_groups << @group1        
        @group3 = create( :group, :name => @name_match ); @group3.parent_groups << @group2
        @matching_groups = [ @group1, @group3 ]
        @not_matching_groups = [ @group2 ]
      end
      subject { @group.descendant_groups_by_name( @name_match ) }
      it "should return all descendant groups matching the name" do
        @matching_groups.each { |g| subject.should include( g ) }
        @not_matching_groups.each { |g| subject.should_not include( g ) }
      end
    end

    describe "#corporation" do
      before do
        @group = create(:group)
        @corporation = create(:corporation)
      end
      subject { @group.reload.corporation }
      describe "for the group being a corporation" do
        before { @group = @corporation }
        it "should return self" do
          subject.should == @group
        end
      end
      describe "for the group being a child of a corporation" do
        before { @group.parent_groups << @corporation }
        it "should return the parent" do
          subject.should == @corporation 
        end
      end
      describe "for the group being a descendant of a corporation" do
        before do
          @middle_group = @group.parent_groups.create
          @middle_group.parent_groups << @corporation
        end
        it "should return the ancestor" do
          subject.should == @corporation
        end
      end
      describe "for the group being not related to a corporation" do
        it "should return nil" do
          subject.should == nil
        end
      end
    end
    
    describe "#corporation?" do
      subject { @group.corporation? }
      describe "for the group being a corporation" do
        before { @group = create(:corporation) }
        it { should == true }
      end
      describe "for the group not being a corporation" do
        before { @group = create(:group) }
        it { should == false }
      end
      describe "for the group being a child of a corporation" do
        before do
          @group = create(:group)
          @group.parent_groups << create(:corporation)
        end
        it { should == false }
      end
    end
    
    describe '#leaf_groups' do
      subject { @group.leaf_groups }
      describe 'for the group being a corporation' do
        before { @group = create(:corporation) }
        it { should == [] }
      end
      describe 'for the group being a corporation with status groups' do
        before do
          @group = create(:corporation_with_status_groups)
          @status_groups = @group.status_groups
        end
        it { should == @status_groups }
      end
      describe 'for the group being a corporation with admin, normal and status groups' do
        before do
        @group = create(:corporation)
        @group.find_or_create_admins_parent_group
        @status_1 = @group.child_groups.create
        @group_a = @group.child_groups.create
        @status_2 = @group_a.child_groups.create
        @group_b = @group.child_groups.create
        @status_3 = @group_b.child_groups.create
        end
        it 'should contain all status groups' do 
          should include(@status_1)
          should include(@status_2)
          should include(@status_3)
          should_not include(@group_a)
          should_not include(@group_b)
          should_not include(@group.admins_parent)
        end
      end
    end

    describe '#cached(:leaf_groups)' do
      subject { @group.reload.cached(:leaf_groups) }
      describe 'for the group being a corporation' do
        before do
          @group = create(:corporation)
          @group.cached(:leaf_groups)
        end
        it { should == @group.leaf_groups }
      end
      describe 'for the group being a corporation with status groups' do
        before do
          @group = create(:corporation_with_status_groups)
          @group.cached(:leaf_groups)
        end
        it { should == @group.cached(:leaf_groups) }
      end
      describe 'for the group being a corporation with admin groups' do
        before do
          @group = create(:corporation)
          @group.cached(:leaf_groups)
          @group.find_or_create_admins_parent_group
        end
        it { should == @group.leaf_groups }
      end
      describe 'for the group being a corporation with normal and status groups' do
        before do
          @group = create(:corporation)
          @group.cached(:leaf_groups)
          wait_for_cache
          
          # The creation of this group structure should reset the cache.
          @status_1 = @group.child_groups.create
          @group_a = @group.child_groups.create
          @status_2 = @group_a.child_groups.create
          @group_b = @group.child_groups.create
          @status_3 = @group_b.child_groups.create
        end
        it { should == @group.leaf_groups }
      end
    end
  end


  # Adding objects
  # --------------

  describe "#<<" do
    before { @group = create(:group) }
    subject { @group << @object_to_add }
    
    describe "(user)" do
      before do
        @user = create(:user)
        @object_to_add = @user
      end
      it "should add the user as a child user" do
        @group.child_users.should_not include @user
        subject
        @group.reload.child_users.should include @user
      end
      it "should set the valid_from attribute on the membership" do
        subject
        UserGroupMembership.with_invalid.find_by_user_and_group(@user, @group).valid_from.should > 1.second.ago
      end
    end
    
    describe "(group)" do
      before do
        @subgroup = create(:group)
        @object_to_add = @subgroup
      end
      it "should add the group as a subgroup" do
        @group.child_groups.should_not include @subgroup
        subject
        @group.child_groups.should include @subgroup
      end
    end
  end

end
