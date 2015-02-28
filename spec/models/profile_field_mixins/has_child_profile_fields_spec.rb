require 'spec_helper'

module ProfileFieldTypes
  class TestProfileField < ProfileField

    has_child_profile_fields :field_a, :field_b
  end
end

describe ProfileFieldMixins::HasChildProfileFields do

  before do
    @profile_field = ProfileFieldTypes::TestProfileField.new
  end

  subject { @profile_field }
  it { should respond_to( :field_a ) }
  it { should respond_to( :field_a= ) }
  it { should respond_to( :field_b ) }
  it { should respond_to( :field_b= ) }

  describe "#field_a=" do
    before { @new_value = "New Value" }
    subject { @profile_field.field_a = @new_value }
    it "should set the field_a value" do
      subject
      @profile_field.field_a.should == @new_value
    end
    it "should set the value of the associated child" do
      @profile_field.children.first.value.should_not == @new_value if @profile_field.children.first
      subject
      @profile_field.children.first.value.should == @new_value
    end
    specify "saving should make the value persistent" do
      subject
      @profile_field.save
      ProfileField.find(@profile_field.id).field_a.should == @new_value
    end
  end

  describe "#field_a" do
    before { @new_value = "Foo Bar" }
    subject { @profile_field.field_a }
    describe "after setting the value using the setter" do
      before { @profile_field.field_a = @new_value }
      it { should == @new_value }
    end
    describe "after setting the child's value manually" do
      before { @profile_field.find_or_build_child_by_key( :field_a ).value = @new_value }
      it { should == @new_value }
    end
  end

  describe "#save" do
    subject { @profile_field.save }
    it "should also save the child profile fields" do
      subject
      @profile_field.children.count.should == 2
      @profile_field.children.first.label.should == "field_a"
      @profile_field.children.second.label.should == "field_b"
    end
  end

  describe ".create" do
    subject { @profile_field = ProfileFieldTypes::TestProfileField.create }
    it "should create the children as well" do
      subject
      @profile_field.children.count.should == 2
      ProfileField.find(@profile_field.id).children.count.should == 2
    end
  end

end
