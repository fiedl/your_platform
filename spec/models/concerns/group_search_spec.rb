require 'spec_helper'

describe GroupSearch do
  before do
    @germany = create :group, name: "Germany"
    @austria = create :group, name: "Austria"
    @german_chancellor = @germany.create_officer_group name: "Chancellor"
    @austrian_chancellor = @austria.create_officer_group name: "Chancellor"
  end

  subject { Group.search(@query) }

  describe "when the query matches the group name" do
    before { @query = "Germany" }
    it { should include @germany }
  end

  describe "when the query matches a part of the group name" do
    before { @query = "German" }
    it { should include @germany }
  end

  describe "when the query matches parts of the breadcrumb path of the group" do
    before { @query = "German Chancellor" }
    it { should include @german_chancellor }
    it { should_not include @austrian_chancellor }
  end

  describe "when the query does not include at least a part of the group name" do
    before { @query = "German" }
    it { should_not include @german_chancellor }
  end
end