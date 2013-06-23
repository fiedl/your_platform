require 'spec_helper'
require 'cancan/matchers'

describe "Group (:former_members_parent)" do
  before { @group = create(:group) }
  subject { @group }

  describe "for the group being a :former_members_parent group" do
    before { @group.add_flag :former_members_parent }

    specify "an admin should see it" do
      ability = Ability.new( create(:admin) )
      ability.should be_able_to :read, subject
    end
    specify "a non-admin should not see it" do
      ability = Ability.new( create(:user) )
      ability.should_not be_able_to :read, subject
    end
  end

  describe "for the group being a child of a :former_members_parent group" do
    before do
      @parent_group = create(:group)
      @parent_group.add_flag :former_members_parent
      @parent_group.child_groups << @group
    end
    
    specify "an admin should see it" do
      ability = Ability.new( create(:admin) )
      ability.should be_able_to :read, subject
    end
    specify "a non-admin should not see it" do
      ability = Ability.new( create(:user) )
      ability.should_not be_able_to :read, subject
    end
  end

end
