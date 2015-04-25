require 'spec_helper'

describe Bookmark do

  before do
    @user = create( :user )
    @bookmarks = []
    @bookmarked_objects = [ create( :user ), create( :page ), create( :group ) ].each do |obj|
      @bookmarks << Bookmark.create( user: @user, bookmarkable: obj )
    end
    @unbookmarked_objects = [ create( :page ) ]
    @object_to_bookmark = create( :group )
  end

  specify "spec setup should be done properly" do
    @user.should be_kind_of User
    @bookmarks.should be_kind_of Array
    @bookmarks.length.should == 3
    @bookmarked_objects.length.should == @bookmarks.length
  end


  # Finder Methods
  # ==========================================================================================
  
  describe ".find_by" do
    subject { Bookmark.find_by( user: @user, bookmarkable: @bookmarked_objects.first ) }
    it "should return an object, not an ActiveRecord::Relation" do
      subject.should_not be_kind_of ActiveRecord::Relation 
      subject.should be_kind_of Bookmark
    end
    it "should return the first matching object" do
      subject.should == @bookmarks.first
    end
  end

  describe ".find_all_by_user" do
    subject { Bookmark.find_all_by_user( @user ) }
    it { should == @bookmarks }
  end

  describe ".find_all_by_bookmarkable" do
    subject { Bookmark.find_all_by_bookmarkable( @bookmarked_objects.first ) }
    it { should include @bookmarks.first }
    it { should_not include @bookmarks.last }
  end

  describe ".find_by_user_and_bookmarkable" do
    subject { Bookmark.find_by_user_and_bookmarkable( @user, @bookmarked_objects.first ) }
    it { should == @bookmarks.first }
  end


  # API Export // Data Serialization
  # ==========================================================================================

  describe "#serializable_hash" do
    it "should include the bookmarkable object's title" do
      @bookmarks.each do |bookmark| # check it for several types of bookmarks
        bookmark.serializable_hash['bookmarkable']['title'].should == bookmark.bookmarkable.title
      end
    end
    # it "should include the bookmarkable object's url" do
    #   @bookmarks.each do |bookmark|
    #     bookmark.serializable_hash['bookmarkable']['url'].should == bookmark.bookmarkable.url
    #   end
    # end
  end

end
