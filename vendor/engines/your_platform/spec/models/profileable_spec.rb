require 'spec_helper'

unless ActiveRecord::Migration.table_exists? :my_structureables
  ActiveRecord::Migration.create_table :my_structureables do |t|
    t.string :name
  end
end

describe Profileable do

  before do
    class MyStructureable < ActiveRecord::Base
      attr_accessible :name
      is_structureable( ancestor_class_names: %w(MyStructureable),
                        descendant_class_names: %w(MyStructureable Group User Workflow Page) )
    end
  end
  
  describe ".is_profileable" do
    before do
      class MyStructureable
        is_profileable
      end
      @profileable = MyStructureable.create
    end
    subject { @profileable }
    it "should have the profile_fields association now" do
      subject.should respond_to :profile_fields
    end
    it "should have the Profileable instance methods now" do
      subject.should respond_to :profile_fields_by_type
    end
  end

  describe ".has_profile_fields" do  # alias method for is_profileable
    before do
      class MyStructureable
        has_profile_fields
      end
      @profileable = MyStructureable.create
    end
    subject { @profileable }
    it "should have the Profileable instance methods now" do
      subject.should respond_to :profile_fields_by_type
    end
  end

  describe "(instance methods)" do
    before do
      class MyStructureable
        is_profileable
      end
      @profileable = MyStructureable.create
    end
    
    describe "#email=" do
      subject { @profileable.email = "foo@example.com" }
      it "should create an email profile field" do
        subject
        @profileable.profile_fields.last.should be_kind_of ProfileField
        @profileable.profile_fields.last.type.should == "ProfileFieldTypes::Email"
        @profileable.profile_fields.last.value.should == "foo@example.com"
      end
    end
    describe "#email" do
      before do
        @profileable.profile_fields.create(label: "Email", value: "bar@example.com", type: "ProfileFieldTypes::Email")
        @profileable.profile_fields.create(label: "Email 2", value: "baz@example.com", type: "ProfileFieldTypes::Email")
      end
      subject { @profileable.email }
      it "should return the value of the first email profile field" do
        subject.should == "bar@example.com"
      end
    end
    
    describe "#profile" do
      subject { @profileable.profile }
      it { should be_kind_of Profile }
      its(:profileable) { should == @profileable }
    end
    
    describe "#profile_section_titles" do
      subject { @profileable.profile_section_titles }
      it "should be an array of titles" do
        subject.should be_kind_of Array
        subject.first.should be_kind_of Symbol
      end
      it "should include the proper sections for default" do
        subject.should include :contact_information, :about_myself, :study_information, :career_information, :organizations, :bank_account_information, :description 
      end
    end
    
    describe "#profile_sections" do
      subject { @profileable.profile_sections }
      it "should be an array of ProfileSection objects" do
        subject.should be_kind_of Array
        subject.first.should be_kind_of ProfileSection
      end
      it "should include the proper sections for default" do
        subject.collect { |section| section.title }.should include :contact_information, :about_myself, :study_information, :career_information, :organizations, :bank_account_information, :description 
      end
    end
    
    describe "#profile_fields_by_type" do
      before do
        @address_field = @profileable.profile_fields.create(type: "ProfileFieldTypes::Address", value: "Berliner Platz 1, Erlangen")
        @phone_field = @profileable.profile_fields.create(type: "ProfileFieldTypes::Phone", value: "123-456789")
      end
      describe "providing the exact type" do
        subject { @profileable.profile_fields_by_type("ProfileFieldTypes::Address") }
        it "should return the matching profile fields" do
          subject.should == [ @address_field.becomes(ProfileFieldTypes::Address) ]
        end
      end
    end
    
    describe "#profile_fields" do
      before do
        @profileable.profile_fields.create(type: "ProfileFieldTypes::Address", value: "Berliner Platz 1, Erlangen")
      end
      subject { @profileable.profile_fields }
      it "should be an Array of ProfileFields" do
        subject.should be_kind_of Array
        subject.first.should be_kind_of ProfileField
      end
      describe "#to_json" do
        subject { @profileable.profile_fields.to_json }
        it "should not raise an error" do
          expect { subject }.to_not raise_error
        end
      end
    end
  end
  
  describe "creating profile fields for a User: " do
    before do
      @profileable = create(:user)
    end
    specify "simple profile fields" do
      @profileable.profile_fields.create( type: "ProfileFieldTypes::Custom", label: "ICQ", value: "12345678" )
      @profileable.profile_fields.create( type: "ProfileFieldTypes::Phone", label: "Phone", value: "123-45678" )
      @profileable.profile_fields.count.should == 3  # one is email
    end
    specify "complex profile fields (with child fields)" do
      bank_account = @profileable.profile_fields.create( type: "ProfileFieldTypes::BankAccount", label: "Account" )
        .becomes ProfileFieldTypes::BankAccount
      bank_account.account_holder = "John Doe"
      bank_account.save
      @profileable.profile_fields.should include bank_account
    end
  end
end
