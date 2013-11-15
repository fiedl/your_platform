# -*- coding: utf-8 -*-
require 'spec_helper'

# The dag link functionality is tested extensively in the corresponding gems `acts-as-dag` and ´acts_as_paranoid_dag`.
# This test is just to make sure that the integration is propery done. Therefore, some basic scenarios are tested here.
#
# We use the Page model here to represent the dag's node objects, since it's a relatively simple model, which is already
# present in the database. If the Page model should become more extensive in the future, it's recommended to refactor
# this test to use a new model, perhaps defined in the test itself.


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

describe DagLink do

  def setup_dag_links 
    @page1 = create( :page )
    @page2 = create( :page )
    @page3 = create( :page )
    @page1.parent_pages << @page2
    @invalid_dag_link = @page1.links_as_child.first
    @invalid_dag_link.update_attribute(:valid_to, 1.hour.ago)
    @page1.parent_pages << @page3
    @present_dag_link = @page1.links_as_child.last
  end

  before { setup_dag_links }
  subject { DagLink }

  describe ".now" do
    it "should list all dag links that are not invalid now" do
      subject.now.should include( @present_dag_link )
      subject.now.should_not include( @invalid_dag_link )
    end
  end
  describe ".in_the_past" do
    it "should list all dag links that are invalid now" do
      subject.in_the_past.should include( @invalid_dag_link )
      subject.in_the_past.should_not include( @present_dag_link )
    end
  end
  describe ".now_and_in_the_past" do
    it "should list all dag links" do
      subject.now_and_in_the_past.should include( @invalid_dag_link, @present_dag_link )
    end
  end

end
