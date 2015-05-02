require 'spec_helper'

# We use the Page model here as an example, since it is already represented in the database.
#
#   class Page < ActiveRecord::Base
#     is_structureable ...
#     ...
#   end

describe Structureable do

  describe ".is_structureable" do

    before { @node = create( :page ) }
    subject { @node }

    it "should provide the has_dag_links functionality" do
      subject.should respond_to( :parents, :children, :ancestors, :descendants )
    end

    it "should provide the has_many_flags functionality" do
      subject.should respond_to( :flags, :add_flag, :remove_flag )
    end

    it "should make sure that when objects are destroyed, also their dag links are destroyed" do
      @parent = create( :page )
      @parent.child_pages << @node
      @node.destroy
      @parent.links_as_parent.count.should == 0
    end

  end
  
  describe "#move_to" do
    subject { @node.move_to @new_parent }
    
    before do
      @parent = create :group
      @new_parent = create :group
      @user = create :user
    end
    
    [:group, :page, :event, :user].each do |kind_of_node|
      describe "for a #{kind_of_node} node" do
       
        before { @node = create kind_of_node }
        
        describe "if the node has no parent" do
          it "should should set the given parent as parent node" do
            @node.parents.should == []
            subject
            @node.reload.parents.should == [@new_parent]
          end
        end
        describe "if the node has one parent" do
          before { @parent << @node }
          it "should remove the old relation" do
            @node.parents.should == [@parent]
            subject
            @node.reload.parents.should_not include @parent
          end
        end
        describe "if the new parent is the old parent" do
          before do
            @parent << @node
            @new_parent = @parent
          end
          it "should not change the existing relation" do
            @links_before = @node.links_as_child
            subject
            @node.reload.links_as_child.should == @links_before
          end
        end
      
      end
    end
    
    describe "moving a group from a group to a page" do
      before do
        @node = create :group
        @parent = create :group
        @new_parent = create :page
        @parent << @node
      end
      it "should move the object without error" do
        @node.parents.should == [@parent]
        subject
        @node.reload.parents.should_not include @parent
      end
      
      describe "when the node has a child user" do
        before { @node << @user }
        it "should keep the group-user relation" do
          subject
          @node.child_users.should == [@user]
        end
        it "should create an ancestor relation between the new parent and the child user" do
          subject
          @user.reload.ancestors.should include @new_parent
          @user.ancestors.should_not include @parent
        end
      end
    end
    
    describe "moving a group from a group to another group" do
      before do
        @node = create :group
        @parent = create :group
        @new_parent = create :group
        @parent << @node
      end
      
      describe "when the node has a child user" do
        before { @node << @user }
        describe "when the child user is already a child of the new parent" do
          before { @new_parent << @user }
          it "should still work" do
            @user.ancestors.should include @new_parent
            subject
            @user.reload.ancestors.should include @new_parent, @node
            @user.ancestors.should_not include @parent
          end
        end
      end
    end
    
    describe "#<<" do
      subject { @parent << @child }
      describe "adding a group to a group" do
        before do
          @parent = create :group
          @child = create :group
        end
        
        it "should add the group as child group of the parent group" do
          subject
          @parent.child_groups.should include @child
        end
        
        describe "if they have a common user" do
          before do
            @user = create :user
            @parent << @user
            @child << @user
          end
          it "should add the group as child group of the parent group" do
            subject
            @parent.child_groups.should include @child
          end
        end
        
        # Example: 
        #
        #   Alle Amtsträger
        #         |-------- Alle Seniores -------.
        #         |                              |
        #         |                              |
        #         |-- << -- Alle Admins ------- User 
        # 
        describe "when it creates a second connection to a user" do
          before do
            @parent.update_attributes name: 'Alle Amtsträger'
            @alle_seniores = @parent.child_groups.create name: 'Alle Seniores'
            @user = create(:user)
            @alle_seniores.assign_user @user
            @child.update_attributes name: 'Alle Admins'
            @child.assign_user @user
          end
          it "should add the group as child group of the parent group" do
            subject
            @parent.child_groups.should include @child
          end
        end
        
      end
    end
  end
end
