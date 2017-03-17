require 'spec_helper'

describe DagLink do
  describe ".create" do
    before do
      @user = create :user
      @group = create :group
    end

    describe "when creating directly" do
      subject { DagLink.create ancestor_type: "Group", ancestor_id: @group.id, descendant_type: "User", descendant_id: @user.id }
      it { should be_kind_of DagLink }
      its(:type) { should == "Membership" }

      it "should create indirect memberships along" do
        @super_group = @group.parent_groups.create name: "Super group"
        subject
        @user.links_as_descendant.where(direct: true).count.should == 1
        @user.links_as_descendant.where(direct: false).count.should == 1
        @user.memberships.count.should == 2
        @user.direct_memberships.count.should == 1
        @user.indirect_memberships.count.should == 1
      end
    end

    describe "when creating through an association" do
      subject { @group.links_as_parent.create descendant_type: "User", descendant_id: @user.id }
      it { should be_kind_of DagLink }
      its(:type) { should == "Membership" }
    end

    describe "when using the << operator" do
      subject { @group << @user }
      it { should be_kind_of Membership }
    end
  end
end

# The dag link functionality is tested extensively in the corresponding `acts-as-dag` gem.
# This test is just to make sure that the integration is propery done. Therefore, some basic scenarios are tested here.
#
# We use the Page model here to represent the dag's node objects, since it's a relatively simple model, which is already
# present in the database. If the Page model should become more extensive in the future, it's recommended to refactor
# this test to use a new model, perhaps defined in the test itself.
#
describe "Page (DagLinkNode)" do

  def setup_pages
    @page = FactoryGirl.create( :page )
    @parent = FactoryGirl.create( :page )
    @grandfather = FactoryGirl.create( :page )
    @page.parent_pages << @parent
    @parent.parent_pages << @grandfather
  end

  before { setup_pages }

  describe "#ancestors" do
    it "should return all ancestors, not only the parents" do
      @page.ancestors.should include( @parent, @grandfather )
    end
  end

  describe "#descendants" do
    it "should return all descendants, not only the children" do
      @grandfather.descendants.should include( @parent, @page )
    end
  end

  describe "#parents" do
    it "should return only the parents rather than all ancestors" do
      @page.parents.should include( @parent )
      @page.parents.should_not include( @grandfather )
    end
  end

  describe "#children" do
    it "should return only the children rather than all descendants" do
      @grandfather.children.should include( @parent )
      @grandfather.children.should_not include( @page )
    end
  end

end
