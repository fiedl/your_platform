require 'spec_helper'

if GraphDatabase::Base.configured?
  describe GraphDatabase::Group do

    before { GraphDatabase::Base.clean :yes_i_am_sure }

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
end