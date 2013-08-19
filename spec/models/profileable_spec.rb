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
  
  describe "#profile_field_type_by_section" do
    describe "section :general" do
      subject { @profileable.profile_field_type_by_section(:general) }
      it { should include "ProfileFieldTypes::Klammerung" }
    end
  end
end
