require 'spec_helper'

describe DagLink do
  # Changes on dag links are reflected on attributes of dag nodes (e.g. Users, Groups, etc.).
  # Therefore, it is important to invalidate or renew the cache of these objects.
  #
  describe "(Cache Callbacks)" do
    before do
      
      class User
        def cached_group_names
          cached { self.groups.pluck(:name) }
        end
      end
      class Group
        def cached_member_names
          cached { self.members.collect(&:name) }
        end
      end
      
      @user = create :user
      @group = create :group
      @membership = @group.assign_user @user
      
      @user.cached_group_names
      @group.cached_member_names
    end
    
    describe "after_destroy" do
      describe "through the parent object" do
        subject { @group.members.destroy(@user); time_travel(2.seconds); @user.reload; @group.reload }
        it "should delete the cache of the associated child object" do
          subject
          Rails.cache.read([@user, 'cached_group_names']).present?.should be_false
        end
        it "should delete the cache of the associated parent object" do
          subject
          Rails.cache.read([@group, 'cached_member_names']).present?.should be_false
        end
      end
      describe "through the child object" do
        subject { @user.groups.destroy(@group); time_travel(2.seconds); @user.reload; @group.reload }
        it "should delete the cache of the associated child object" do
          subject
          Rails.cache.read([@user, 'cached_group_names']).present?.should be_false
        end
        it "should delete the cache of the associated parent object" do
          subject
          Rails.cache.read([@group, 'cached_member_names']).present?.should be_false
        end
      end
            
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