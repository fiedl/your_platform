require 'spec_helper'

describe GraphDatabase::Group do

  before do
    @group = create :group
    @subgroup = @group.child_groups.create
    @user = create :user
    @subgroup.assign_user @user
  end

  describe ".get_member_ids" do
    subject { GraphDatabase::Group.get_member_ids @group }
    it { should == [@user.id] }
  end

end