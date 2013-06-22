require 'spec_helper'
require 'cancan/matchers'

describe User do
  before { @user = create(:user) }
  subject { @user }
  describe "for the user being hidden: " do
    before { @user.hidden = true }
    
    specify "an admin should see the hidden user" do
      ability = Ability.new( create(:admin) )
      ability.should be_able_to :read, subject
    end
    specify "the user should see himself" do
      ability = Ability.new( subject )
      ability.should be_able_to :read, subject
    end
    specify "a non-admin should not see the hidden user" do
      ability = Ability.new( create(:user) )
      ability.should_not be_able_to :read, subject
    end
  end
end
