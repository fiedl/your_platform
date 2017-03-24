require 'spec_helper'

describe ProfileableMixins::Address do
  
  # We use a User as an example Profileable.
  let(:user) { create :user }
  
  describe "#address_fields" do
    subject { user.address_fields }
    describe "for a regular user with address and phone field" do
      before do
        @address_field = user.profile_fields.create type: 'ProfileFields::Address', label: 'Study Address', value: ''
        @phone_field = user.profile_fields.create type: 'ProfileFields::Phone', label: 'Phone', value: '1234'
      end
      it { should include @address_field.becomes(ProfileFields::Address) }
      it { should_not include @phone_field }
      it { should_not include @phone_field.becomes(ProfileFields::Address) }
      it { should_not include @phone_field.becomes(ProfileFields::Phone) }
    end

    describe "when unsaved user without id" do
      let(:user) { User.new }
      describe "when address fields without profileable_id exist (bug fix)" do
        before { ProfileField.create(type: 'ProfileFields::Address', profileable_type: 'User', label: 'Test', value: 'Test') }
        specify { user.id.should == nil }
        it { should == [] }
        it { should be_kind_of ActiveRecord::Relation }
      end
    end
  end
  
  describe "#study_address" do
    subject { user.study_address }
    it "should return the value of a given study address field" do
      @address_field = user.address_fields.create label: "Study Address", value: "My Study Address"
      subject.should == @address_field.value

      @address_field.update_attributes label: "Semesteranschrift", value: "Meine Semesteranschrift"
      user.study_address.should == @address_field.value

      @address_field.update_attributes label: "Studienanschrift", value: "Meine Studienanschrift"
      user.study_address.should == @address_field.value

      @address_field.update_attributes label: "Sonstige Anschrift", value: "Noch eine andere Anschrift"
      user.study_address.should_not == @address_field.value
    end
  end
  describe "#study_address=" do
    subject { user.study_address = "My New Study Address" }
    describe "when not present" do
      it "should create an address field" do
        user.address_fields.count.should == 0
        subject
        user.address_fields.first.value.should == "My New Study Address"
        user.address_fields.first.label.should == user.study_address_labels.first
      end
    end
    describe "when already present" do
      before { @address_field = user.profile_fields.create type: 'ProfileFields::Address', label: 'Study Address', value: '' }
      it "should update the existing field" do
        subject
        @address_field.reload.value.should == "My New Study Address"
      end
      it "should not change the label" do
        subject
        @address_field.reload.label.should == 'Study Address'
      end
    end
    describe "when study-or-work address present" do
      before { @address_field = user.profile_fields.create type: 'ProfileFields::Address', label: 'Arbeits- oder Studienanschrift', value: '' }
      it "should update the existing field" do
        subject
        @address_field.reload.value.should == "My New Study Address"
      end
      it "should change the existing (ambiguous) label" do
        subject
        @address_field.reload.label.should == user.study_address_labels.first
      end
    end
  end
  
  describe "#work_address" do
    specify { user.should respond_to :work_address }
    specify { user.should respond_to :work_address= }
  end
  
  describe "#home_address" do
    specify { user.should respond_to :home_address }
    specify { user.should respond_to :home_address= }
  end
  
  
end