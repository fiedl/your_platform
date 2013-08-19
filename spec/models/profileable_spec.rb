require 'spec_helper'

describe Profileable do
  before do
    class MyStructureable < ActiveRecord::Base
      attr_accessible :name
      is_structureable( ancestor_class_names: %w(MyStructureable),
                        descendant_class_names: %w(MyStructureable Group User Workflow Page) )
      has_profile_fields
    end
    @profileable = MyStructureable.create
  end
  
  describe "#profile" do
    describe "#sections.select(general)" do
      describe "#profile_field_types" do
        subject { @profileable.profile.section_by_title(:general).profile_field_types }
        it { should include "ProfileFieldTypes::Klammerung" }
      end
    end
  end
end
