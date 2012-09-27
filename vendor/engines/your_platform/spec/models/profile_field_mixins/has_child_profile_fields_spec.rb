require 'spec_helper'

class TestProfileField < ProfileField

  has_child_profile_fields :field_a, :field_b

end

describe ProfileFieldMixins::HasChildProfileFields do
  
  before do
    @profile_field = TestProfileField.create() # which triggers has_child_profile_fields( :field_a, :field_b )
  end
  subject { @profile_field }

  it "should auto-create the child profile fields" do
    subject.children.count.should == 2
    subject.children.first.label.should == "field_a"
    subject.children.second.label.should == "field_b"
  end

  it { should respond_to( :field_a ) }
  it { should respond_to( :field_a= ) }
  it { should respond_to( :field_b ) }
  it { should respond_to( :field_b= ) }

  describe "#field_a" do
    before do
      @new_value = "New Value"
      @profile_field.children.first.update_attribute( :value, @new_value )
    end
    it "should get the value of the child field" do
      @profile_field.field_a.should == @new_value
    end
  end

  describe "#field_a=" do
    before do
      @new_value = "New Value" 
      @profile_field.field_a = @new_value
    end
    it "should set the field_a value" do
      @profile_field.field_a.should == @new_value 
    end
    it "should set the value of the associated child after saving" do
      @profile_field.children.first.value.should_not == @new_value
      @profile_field.save
      @profile_field.children.first.value.should == @new_value
    end
  end

end
