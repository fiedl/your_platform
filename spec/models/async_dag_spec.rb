require 'spec_helper'

describe "Async DAG" do
  before do
    Sidekiq::Testing.fake!

    @user = create :user
    @group = create :group, name: "group"
    @super_group = create :group, name: "super_group"
    @super_super_group = create :group, name: "super_super_group"
    @super_super_super_group = create :group, name: "super_super_super_group"
  end

  describe "@super_group being parent of @group" do
    before do
      @super_group << @group; @super_group.reload
      @super_super_group << @super_group; @super_super_group.reload
      @super_super_super_group << @super_super_group; @super_super_super_group.reload
    end

    describe "@user being member of @group" do
      before { @group.assign_user @user }

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
  end

  after { Sidekiq::Worker.clear_all }
end