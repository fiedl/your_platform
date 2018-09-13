require 'spec_helper'

describe "Async DAG" do
  before do
    Sidekiq::Testing.fake!
  end

  describe "for a user with ancestor groups" do
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

    describe "User#current_ancestor_groups" do
      subject { @user.current_ancestor_groups }

      it { should include @group }
      it { should_not include @super_group }
      it { should_not include @super_super_group }
      it { should_not include @super_super_super_group }

      describe "after the background jobs are done" do
        before { Sidekiq::Worker.drain_all }

        it { should include @super_group }
        it { should include @super_super_group }
        it { should include @super_super_super_group }
      end
    end

    describe "User#current_parent_groups" do
      subject { @user.current_parent_groups }

      it { should include @group }
      it { should_not include @super_group }
    end
  end

  describe "for a user in two groups with a common ancestor group" do
    before do
      @user = create :user
      @direct_group_1 = create :group
      @direct_group_2 = create :group
      @ancestor_group = create :group

      @ancestor_group << @direct_group_1
      @ancestor_group << @direct_group_2

      @direct_group_1.assign_user @user
      @direct_group_2.assign_user @user
    end

    describe "User#current_ancestor_groups" do
      subject { @user.current_ancestor_groups }

      it { should include @direct_group_1 }
      it { should include @direct_group_2 }
      it { should_not include @ancestor_group }

      describe "after the background jobs are done" do
        before { Sidekiq::Worker.drain_all }

        it { should include @ancestor_group }
      end
    end

    describe "User#current_parent_groups" do
      subject { @user.current_parent_groups }

      it { should include @direct_group_1 }
      it { should include @direct_group_2 }
      it { should_not include @ancestor_group }
    end
  end

  after { Sidekiq::Worker.clear_all }
end