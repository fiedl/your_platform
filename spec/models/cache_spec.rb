require 'spec_helper'

describe "cache" do
  
  describe "cache_timestamp_format" do
    subject { User.cache_timestamp_format}
    it { should == :number }
  end
  
  describe "cache_key" do
    before { @user = create :user }
    subject { @user.cache_key }
    its(:length) { should == "users/4190-20151103154958".length } 
  end
  
  describe "after storing the User#title in the cache" do
    
    class User
      def title
        cached { "#{self.personal_title} #{self.name}".strip }
      end
    end
    before { @user = create :user; @user.title }
    
    describe "Rails.cache.ls (Rails.cache.list_keys)" do
      subject { Rails.cache.ls @user }
      its(:count) { should >= 1}
      it { should include "#{@user.cache_key}/title" }
    end
    
    describe "#delete_cache" do
      subject { @user.delete_cache}
      it "should remove all cache entries under the user's scope" do
        Rails.cache.ls(@user).count.should >= 1
        subject
        Rails.cache.ls(@user).count.should == 0
      end
    end
  end
  
end