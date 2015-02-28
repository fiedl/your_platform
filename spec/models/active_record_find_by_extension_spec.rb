require 'spec_helper'

describe ActiveRecordFindByExtension do

  # The extension described here applies to all ActiveRecord::Base models.
  # Therefore, we pick the user model, here.

  before do
    @user = create( :user )
    @other_user = create( :user )
  end

  describe ".find_by" do
    subject { User.find_by( first_name: @user.first_name, last_name: @user.last_name ) }
    it "should return an object" do
      subject.should be_kind_of User
    end
    it "should not return an ActiveRecord::Relation" do
      subject.should_not be_kind_of ActiveRecord::Relation
    end
    it "should find the correct object" do
      subject.should == @user
    end
  end

end
