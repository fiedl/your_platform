require 'spec_helper'

describe Groups::CorporationsParent do
  before { Group.destroy_all }

  describe ".find_or_create" do
    subject { Groups::CorporationsParent.find_or_create }

    describe "when already existing" do
      before { @existing_group = Groups::CorporationsParent.create }
      it { should == @existing_group }
      its(:type) { should == "Groups::CorporationsParent" }
    end

    its(:type) { should == "Groups::CorporationsParent" }
  end

end