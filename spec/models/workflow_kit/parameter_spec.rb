require 'spec_helper'

describe WorkflowKit::Parameter do

  describe "Instance" do
    
    before { @parameter = WorkflowKit::Parameter.new }
    subject { @parameter }

    it { should respond_to( :key ) }
    it { should respond_to( :key= ) }
    it { should respond_to( :value ) }
    it { should respond_to( :value= ) }

    describe "#value" do
      describe "for numbers" do
        it "should return an integer" do
          subject.value = "123"
          subject.value.should be_kind_of( Integer )
        end
      end
      describe "for strings" do
        it "should return a string" do
          subject.value = "abc"
          subject.value.should be_kind_of( String )
        end
      end
      describe "for bools" do
        it "should return a boolean" do
          subject.value = "true"
          subject.value.should be_kind_of( TrueClass )
          subject.value = "false"
          subject.value.should be_kind_of( FalseClass ) # there is no Boolean in Ruby.
          # see: http://stackoverflow.com/questions/3192978/why-does-ruby-have-trueclass-and-falseclass-instead-of-a-single-boolean-class
        end
      end
    end

    describe "#to_hash" do
      before { @parameter = WorkflowKit::Parameter.new( key: "KEY", value: "VALUE" ) }
      subject { @parameter.to_hash }
      it { should == { :KEY => "VALUE" } }
    end

  end

  describe "Class" do
    
    subject { WorkflowKit::Parameter }

    describe ".to_hash( parameters )" do

      before do
        @parameters = [ WorkflowKit::Parameter.new( key: "first_key", value: "first_value" ),
                        WorkflowKit::Parameter.new( key: "second_key", value: "second_value" ) ]
      end
      
      subject { WorkflowKit::Parameter.to_hash }

      it "should return a hash of parameters" do
        WorkflowKit::Parameter.to_hash( @parameters ).should ==
          { first_key: "first_value", second_key: "second_value" }
      end

    end

  end

end
