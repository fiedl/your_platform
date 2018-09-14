require 'spec_helper'

describe GroupDag do
  describe "#current_descendant_users" do

    describe "for an ancestor group" do
      before do
        @user = create :user
        @group = create :group, name: "group"
        @super_group = create :group, name: "super_group"
        @super_super_group = create :group, name: "super_super_group"
        @super_super_super_group = create :group, name: "super_super_super_group"

        @super_group << @group; @super_group.reload
        @super_super_group << @super_group; @super_super_group.reload
        @super_super_super_group << @super_super_group; @super_super_super_group.reload

        @group.assign_user @user
      end
      subject { @super_super_super_group.current_descendant_users }

      it { should_not include @user }

      describe "after the background jobs are done" do
        before { Sidekiq::Worker.drain_all }

        it { should include @user }
      end
    end

  end
end


