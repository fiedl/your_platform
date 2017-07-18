require 'spec_helper'

silence_stream(STDOUT) do
  unless ActiveRecord::Migration.table_exists? :my_structureables
    ActiveRecord::Migration.create_table :my_structureables do |t|
      t.string :name
    end
  end
end

describe ProfileSection do

  before do
    class MyStructureable < ApplicationRecord
      has_dag_links ancestor_class_names: %w(MyStructureable), descendant_class_names: %w(MyStructureable Group User Workflow Page), link_class_name: 'DagLink'

      include Structureable
      include HasProfile
    end

    @profileable = MyStructureable.create(name: "My Profileable")
    @general_field = @profileable.profile_fields.create( label: "General Info", value: "Foo Bar", type: "ProfileFields::General")
    @address_field = @profileable.profile_fields.create( label: "Home Address", value: "Berliner Platz 1, Erlangen", type: "ProfileFields::Address" )

    @profile = Profile.new(@profileable)
    @section_title = :contact_information
    @profile_section = @profile.section_by_title(@section_title)
  end

  subject { @profile_section }

  describe "#profileable" do
    subject { @profile_section.profileable }
    it "should return the Profileable the ProfileSection is associated with" do
      subject.should == @profileable
    end
  end

  describe "#title" do
    subject { @profile_section.title }
    it "should return the title of the ProfileSection" do
      subject.should == @section_title
    end
  end

  describe "#profile_fields" do
    subject { @profile_section.profile_fields }
    it "should return the profile fields of the profileable object which belong to this profile section" do
      subject.should be_kind_of ActiveRecord::Relation
      subject.first.should be_kind_of ProfileField
      subject.should include @address_field.becomes(ProfileFields::Address)
      subject.should_not include @general_field.becomes(ProfileFields::General)
    end
    it "should NOT just return all profile fields of the Profileable" do
      subject.should_not == @profileable.profile_fields
    end
  end

  describe "#fields" do
    subject { @profile_section.fields }
    it "should be the same as #profile_fields" do
      subject.should == @profile_section.profile_fields
    end
  end

  describe "#profile_field_types" do
    subject { @profile_section.profile_field_types }
    it "should be an Array of Strings" do
      subject.should be_kind_of Array
      subject.first.should be_kind_of String
    end
    it "should include the corresponding field types" do
      @profile_section.title.to_sym.should == :contact_information
      subject.should include "ProfileFields::Address"
    end
  end

  describe "#field_types" do
    subject { @profile_section.field_types }
    it "should be the same as #profile_field_types" do
      subject.should == @profile_section.profile_field_types
    end
  end

  describe "#to_s" do
    subject { @profile_section.to_s }
    it { should be_kind_of String }
    it { should == @section_title.to_s }
  end

end
