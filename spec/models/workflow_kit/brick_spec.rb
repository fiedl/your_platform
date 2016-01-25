# -*- coding: utf-8 -*-
require 'spec_helper'

describe WorkflowKit::Brick do

  describe "Instance" do

    before { @boil_water_brick = WorkflowKit::BoilWaterBrick.new } # in spec/support/factory.rb
    subject { @boil_water_brick }
    
    it { should respond_to( :name ) }
    it { should respond_to( :description ) }
    
    describe "#execute" do
      it "should execute the brick" do
        @boil_water_brick.execute( :aim_temperature => "100 °C" ).should ==
          "Fill a large pot with water, put it on a cooker and wait until a temperature of 100 °C is reached."
      end
    end

  end

  describe "Class" do
    
    subject { WorkflowKit::Brick }

    describe ".all" do
      subject { WorkflowKit::Brick.all }
      it "should list all inherited classes, i.e. the different kind of WorkflowBricks" do
        (subject & [WorkflowKit::BoilWaterBrick, WorkflowKit::BoilSpaghettiBrick, WorkflowKit::ServeSpaghettiBrick] )
          .should == [WorkflowKit::BoilWaterBrick, WorkflowKit::BoilSpaghettiBrick, WorkflowKit::ServeSpaghettiBrick]
      end
    end

  end

end


