require 'spec_helper'

describe "Async DAG" do
  before do
    @user = create :user
    @group = create :group, name: "group"
    @super_group = create :group, name: "super_group"
  end

  describe "@super_group being parent of @group" do
    before { @super_group << @group; @super_group.reload }

    describe "@user being member of @group" do
      before { @group.assign_user @user }

      describe "User#current_ancestor_groups" do
        subject { @user.current_ancestor_groups }

        it { should include @group }
        it { should include @super_group }
      end

      describe "User#current_parent_groups" do
        subject { @user.current_parent_groups }

        it { should include @group }
        it { should_not include @super_group }
      end

    end
  end
end