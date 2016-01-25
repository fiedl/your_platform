require 'spec_helper'

describe WorkflowKit::Parameterable do
  
  describe "Class" do

    subject { WorkflowKit::Workflow } # since this class extends WorkflowKit::Parameterable

    it { should respond_to ( :has_many_parameters ) }

  end

  describe "Instance" do

    before do 
      @parameterable = WorkflowKit::Workflow.new # since workflows as parameterable, i.e. can have parameters
      @parameterable.parameters = { test_key: "test_value" }
    end
    subject { @parameterable }

    describe "#parameters" do
      subject { @parameterable.parameters }
      it { should be_kind_of( ActiveRecord::Associations::CollectionProxy ) }
      its( :first ) { should be_kind_of WorkflowKit::Parameter }
      its( 'first.key' ) { should == :test_key }
      its( 'first.value' ) { should == "test_value" }
    end

    describe "#parameters_to_hash" do
      subject { @parameterable.parameters_to_hash }
      it { should be_kind_of( Hash ) }
      it { should == { test_key: "test_value" } }
    end

    describe "#parameter_hash" do
      subject { @parameterable.parameter_hash } 
      it { should == @parameterable.parameters_to_hash }
    end

    describe "#parameters=" do 
      it "should transform a parameter hash into WorkflowKit::Parameter objects" do
        @parameterable.parameters = { first_key: "first_value", second_key: "second_value" }
        @parameterable.parameters.should be_kind_of ActiveRecord::Associations::CollectionProxy
        @parameterable.parameters.first.should be_kind_of( WorkflowKit::Parameter )
        @parameterable.parameters.first.key.should == :first_key
      end
      it "should also accept WorkflowKit::Parameter objects" do
        @parameterable.parameters = 
          [ WorkflowKit::Parameter.new( key: :first_key, value: "first_value" ) ]
        @parameterable.parameters.should be_kind_of ActiveRecord::Associations::CollectionProxy
        @parameterable.parameters.first.should be_kind_of( WorkflowKit::Parameter )
        @parameterable.parameters.first.key.should == :first_key
      end
    end
    
  end

end
