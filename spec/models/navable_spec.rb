require 'spec_helper'

describe Navable do
  
  before do
    class MyStructureable < ActiveRecord::Base
      attr_accessible :name
      is_structureable( ancestor_class_names: %w(MyStructureable),
                        descendant_class_names: %w(MyStructureable Group User Workflow Page) )
      is_navable
    end

    @my_structureable = MyStructureable.create( name: "My Structureable" )
  end

  describe "#navable_children" do
    before do
      @workflow = create(:workflow)
      @user = create(:user)
      @page = create(:page)
      @group = create(:group)
      @my_structureable.child_users << @user 
      @my_structureable.child_pages << @page
      @my_structureable.child_groups << @group 
      @my_structureable.child_workflows << @workflow
    end
    subject { @my_structureable.navable_children }
    
    specify "prerequisites" do
      @my_structureable.children.should include @user, @page, @group, @workflow
    end
    it "should include only navable children" do
      subject.each do |child|
        child.should respond_to :nav_node
      end
    end
    it "should include pages, users and groups" do
      subject.should include @page, @user, @group
    end

    # TODO: Maybe, later, Workflow objects become navables.
    # Then, this spec has to be changed accordingly.
    it "should not include workflows" do 
      subject.should_not include @workflow
    end      
  end
  
end
