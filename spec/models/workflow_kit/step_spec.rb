# -*- coding: utf-8 -*-
require 'spec_helper'

describe WorkflowKit::Step do

  before do
    @workflow = create_workflow # in spec/support/factory.rb
    @step = @workflow.steps.first
  end

  subject { @step }
  
  specify "prelims" do
    @step.brick_name.should == "BoilWaterBrick"
  end

  it { should respond_to( :sequence_index ) }
  it { should respond_to( :sequence_index= ) }
  it { should respond_to( :brick_name ) }
  it { should respond_to( :brick_name= ) }
  it { should respond_to( :parameters ) }

  describe "#workflow" do
    subject { @step.workflow }
    it { should == @workflow }
  end

  describe "#execute" do
    subject { @step.execute }
    it "should execute the step" do
      subject.should ==
        "Fill a large pot with water, put it on a cooker and wait until a temperature of 100 °C is reached."
    end
  end
  
  describe "#brick" do
    subject { @step.brick }
    it { should be_kind_of( WorkflowKit::Brick ) }
  end

end


