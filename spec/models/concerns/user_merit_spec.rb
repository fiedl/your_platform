require 'spec_helper'

describe UserMerit do
  before do
    @user = create :user
  end
  
  describe "#grant_badge" do
    subject { @user.grant_badge(@badge_name) }

    describe "for badges that can be granted once" do
      before { @badge_name = 'calendar-uplink' }
      
      it "should grant the badge" do
        @user.badges.count.should == 0
        subject
        @user.badges.count.should == 1
        @user.badges.last.name.should == 'calendar-uplink'
      end
      it "should not grant the badge a second time" do
        @user.badges.count.should == 0
        @user.grant_badge(@badge_name)
        @user.reload.badges.count.should == 1
        @user.badges.last.name.should == 'calendar-uplink'
        subject
        @user.reload.badges.count.should == 1
        @user.badges.last.name.should == 'calendar-uplink'
      end
    end
  end
    
end