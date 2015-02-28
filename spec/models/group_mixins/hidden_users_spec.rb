require 'spec_helper'

describe GroupMixins::HiddenUsers do
  
  describe ".hidden_users" do
    subject { Group.hidden_users }
    describe "for no group existing" do
      it "should create the hidden_users group" do
        subject.should be_kind_of Group
        subject.should have_flag :hidden_users
      end
    end
    describe "for the hidden_users group already existing" do
      before { @hidden_users_group = Group.create_hidden_users_group }
      it "should return the existing group" do
        subject.should == @hidden_users_group 
      end
    end
  end

end
