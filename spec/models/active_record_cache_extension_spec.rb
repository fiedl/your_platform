require 'spec_helper'

describe ActiveRecordCacheExtension do

  # All ActiveRecord::Base classes are extended by this mechanism.
  # We'll take the User model as example here.
  #
  before do
    @user = create(:user)
  end
  
  describe "#cached" do
    subject { @user.cached(:title) }

    describe "with no cached value stored" do
      it "should return the fresh value of the given method" do
        subject.should == @user.reload.title
      end
    end
    describe "with a cached value stored" do
      before do
        @cached_title = @user.cached(:title)
      end
      it "should return the cached value" do
        # Change the title (which contains the last_name) without
        # triggering the cache invalidation.
        @user.update_column :last_name, "Dinglehopper"
        wait_for_cache

        subject.should == @cached_title
        subject.should_not == @user.reload.uncached(:title)
      end
    end
    describe "with a cache in place and the real value having changed" do
      before do
        @old_cached_title = @user.cached(:title)
        wait_for_cache
        @user.last_name = "Dinglehopper"
        @user.save
        wait_for_cache
      end
      it "should return the new value" do
        subject.should == @user.reload.title
        subject.should include "Dinglehopper"
        subject.should_not == @old_cached_title
      end
    end
    
    describe "with method arguments" do
      before do
        @corporation = create(:corporation_with_status_groups)
        @membership = @corporation.status_groups.first.assign_user @user
        time_travel 2.seconds
      end
      subject { @user.reload.corporate_vita_memberships_in(@corporation) }
      describe "with no cached value stored" do
        it "should return the fresh value" do
          subject.should == @user.reload.corporate_vita_memberships_in(@corporation)
          subject.should include @membership
        end
      end
      describe "with a cached value stored" do
        before { @cached_memberships = @user.corporate_vita_memberships_in(@corporation) }
        it "should return the cached value" do
          subject.should == @cached_memberships
          subject.should include @membership
        end
      end
      describe "with a cache in place and the real value having changed" do
        before do
          @old_cached_memberships = @user.corporate_vita_memberships_in(@corporation)
          wait_for_cache
          @new_membership = @membership.move_to @corporation.status_groups.last
          wait_for_cache
        end
        it "should return the new value" do
          subject.should == @user.reload.corporate_vita_memberships_in(@corporation)
          subject.should include @new_membership
        end
      end
    end
  end
  
  describe "#cached { ... }" do
    before do
      class User
        def foo
          cached { Time.zone.now }
        end
      end
      
      @user = create(:user)
    end
    subject { @user.foo }
    
    describe "with no cached value stored" do
      it "should return the fresh value of the given method" do
        subject.should == Rails.cache.uncached { subject }
      end
    end
    describe "with a cached value stored" do
      before do
        @cached_foo = @user.foo
        wait_for_cache
      end
      it "should return the cached value" do
        subject.should == @cached_foo
      end
    end
    describe "with a cache in place and the real value having changed" do
      before do
        @old_cached_foo = @user.foo
        wait_for_cache
        @user.touch
        wait_for_cache
      end
      it "should return the new value" do
        subject.should_not == @old_cached_foo
        subject.should == Rails.cache.uncached { subject }
      end
    end
    describe "calling #cached(:method) when method is defined using a cached block" do
      subject { @user.cached(:foo) }
      before do
        @user.foo
        wait_for_cache
        @user.reload
      end
      it { should == @user.foo }
    end
  end
  
  
  describe "#uncached" do
    subject { @user.uncached(:title) }
    
    describe "with no cached value stored" do
      it "should return the fresh value of the given method" do
        subject.should == @user.reload.title
      end
    end
    describe "with a cached value stored" do
      before do
        @cached_title = @user.cached(:title)

        # Change the title (which contains the last_name) without
        # triggering the cache invalidation.
        @user.update_column :last_name, "Dinglehopper"
        wait_for_cache
      end
      it "should still return the fresh value" do
        subject.should == @user.reload.title
      end
      it "should not return the cached value" do
        subject.should_not == @cached_title
      end
      
      it "should be the same as Rails.cache.uncached { ... }" do
        subject.should == Rails.cache.uncached { @user.reload.title }
      end
    end
    describe "with a cache in place and the real value having changed" do
      before do
        @old_cached_title = @user.cached(:title)
        wait_for_cache
        @user.last_name = "Dinglehopper"
        @user.save
        wait_for_cache
      end
      it "should return the new value" do
        subject.should == @user.reload.title
        subject.should include "Dinglehopper"
        subject.should_not == @old_cached_title
      end
    end
  end
end
