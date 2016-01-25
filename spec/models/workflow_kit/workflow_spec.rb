# -*- coding: utf-8 -*-
require 'spec_helper'

describe WorkflowKit::Workflow do

  before { @workflow = create_workflow } # in spec/support/factory.rb
  subject { @workflow }

  for method in [ :name, :name=, :description, :description= ]
    it { should respond_to( method ) }
  end

  describe "#steps" do
    subject { @workflow.steps }
    it "should list the sequence entries" do
      subject.count.should == 3
    end
    it { should be_kind_of( ActiveRecord::Relation ) }
    its( :first ) { should be_kind_of( WorkflowKit::Step ) }
  end

  describe "#execute" do

    it "should produce the proper recipe" do # according to spec/support/factory.rb
      subject.execute.join( " " ).should ==
        "Fill a large pot with water, put it on a cooker and wait until a temperature of 100 °C is reached. " +
        "Add spaghetti and boil them for 10 minutes. Sieve spaghetti, put them on a plate, and serve them with " +
        "some yummy ham-cheese-cream sauce."
    end

    it "should accept a parameter hash" do
      subject.execute( a: 1, b: 2, c: "3" ).should_not be_nil
    end

  end

end

