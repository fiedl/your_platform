require 'spec_helper'

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
