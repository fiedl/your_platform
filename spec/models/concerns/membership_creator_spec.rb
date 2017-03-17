require 'spec_helper'

describe MembershipCreator do

  before do
    @group = Group.create( name: "Group 1" )
    @super_group = Group.create( name: "Parent Group of Groups 1 and 2" )
    @other_group = Group.create( name: "Group 2" )
    @group.parent_groups << @super_group
    @other_group.parent_groups << @super_group
    @other_user = create(:user)
    @user = User.create( first_name: "John", last_name: "Doe", :alias => "j.doe" )
  end

  describe ".create" do

    describe "when creating directly" do
      subject { Membership.create ancestor_type: "Group", ancestor_id: @group.id, descendant_type: "User", descendant_id: @user.id }
      it { should be_kind_of Membership }
      it "should create indirect memberships along" do
        subject
        @user.links_as_descendant.where(direct: true).count.should == 1
        @user.links_as_descendant.where(direct: false).count.should == 1
        @user.memberships.count.should == 2
        @user.direct_memberships.count.should == 1
        @user.indirect_memberships.count.should == 1
      end
    end

    describe "when creating as DagLink" do
      subject { DagLink.create ancestor_type: "Group", ancestor_id: @group.id, descendant_type: "User", descendant_id: @user.id }
      it { should be_kind_of DagLink }
      its(:type) { should == "Membership"}
      it "should create indirect memberships along" do
        subject
        @user.links_as_descendant.where(direct: true).count.should == 1
        @user.links_as_descendant.where(direct: false).count.should == 1
        @user.memberships.count.should == 2
        @user.direct_memberships.count.should == 1
        @user.indirect_memberships.count.should == 1
      end
    end

    describe "when creating through a dag link association" do
      subject { @group.links_as_parent.create descendant_type: "User", descendant_id: @user.id }
      it { should be_kind_of DagLink }
      its(:type) { should == "Membership"}
      it "should create indirect memberships along" do
        subject
        @user.links_as_descendant.where(direct: true).count.should == 1
        @user.links_as_descendant.where(direct: false).count.should == 1
        @user.memberships.count.should == 2
        @user.direct_memberships.count.should == 1
        @user.indirect_memberships.count.should == 1
      end
    end

    describe "when creating through the << operator" do
      subject { @group << @user }
      it { should be_kind_of Membership }
      it "should create indirect memberships along" do
        subject
        @user.links_as_descendant.where(direct: true).count.should == 1
        @user.links_as_descendant.where(direct: false).count.should == 1
        @user.memberships.count.should == 2
        @user.direct_memberships.count.should == 1
        @user.indirect_memberships.count.should == 1
      end
    end

  end

end