require 'spec_helper'

unless ActiveRecord::Migration.table_exists? :my_structureables
  ActiveRecord::Migration.create_table :my_structureables do |t|
    t.string :name
  end
end

describe Profile do
  
  before do
    class MyStructureable < ActiveRecord::Base
      attr_accessible :name
      is_structureable( ancestor_class_names: %w(MyStructureable),
                        descendant_class_names: %w(MyStructureable Group User Workflow Page) )
      has_profile_fields sections: [ :general, :group ]
    end

    @profileable = MyStructureable.create(name: "My Profileable")
    @address_field = @profileable.profile_fields.create( label: "Home Address", value: "Berliner Platz 1, Erlangen", type: "ProfileFieldTypes::Address" )
    
    @profile = Profile.new(@profileable)
  end
  
  subject { @profile }
  
  describe "#profileable" do
    subject { @profile.profileable }
    it "should return the Profileable the Profile is associated with" do
      subject.should == @profileable
    end
  end
  
  describe "#profile_fields" do
    subject { @profile.profile_fields }
    it "should return the profile fields of the profileable object" do
      subject.should == @profileable.profile_fields
      subject.should include @address_field
    end
  end
  
  describe "#fields" do
    subject { @profile.fields }
    it "should be the same as #profile_fields" do
      subject.should == @profile.profile_fields
    end
  end
  
  describe "#sections" do
    subject { @profile.sections }
    it "should be an array of ProfileSection objects" do
      subject.should be_kind_of Array
      subject.first.should be_kind_of ProfileSection
    end
  end
  
  describe "#section_by_title" do
    subject { @profile.section_by_title(:general) }
    it "should return the ProfileSection where the title matches the given title" do
      subject.should be_kind_of ProfileSection
      subject.title.should.to_s == "general"
    end
  end
  
  describe "#sections_by_title" do
    subject { @profile.sections_by_title([:group, :general]) }
    it "should return an array of ProfileSections where the titles matche the given titles" do
      subject.should be_kind_of Array
      subject.first.should be_kind_of ProfileSection
      subject.collect { |section| section.title }.should == [:group, :general]
    end
  end

end
