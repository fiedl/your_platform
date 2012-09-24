require 'spec_helper'

describe Group do

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

  end

  describe "(Workflows)" do
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


end
