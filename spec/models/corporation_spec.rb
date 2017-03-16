require 'spec_helper'

describe Corporation do
  before do
    @group = create :group
    @corporation = create :corporation
  end

  describe ".create" do
    subject { Corporation.create name: 'My Great Corporation' }

    it { should be_kind_of Corporation }
    it { should be_kind_of Group }
    its(:type) { should == 'Corporation' }

    it "should be child of the corporations_parent group" do
      subject.reload.parent_group_ids.should include Corporation.corporations_parent.id
    end
  end

  describe ".all" do
    subject { Corporation.all }

    it { should include @corporation }
    it { should_not include @group }

    it "should return an array of Corporation-type objects" do
      subject.should be_kind_of ActiveRecord::Relation
      subject.to_a.should be_kind_of Array
      subject.first.should be_kind_of Corporation
    end
    it "should not find the officers_parent group of the corporations_parent" do
      @corporations_parent = Group.find_corporations_parent_group
      @officers_parent = @corporations_parent.create_officers_parent_group
      subject.should_not include @officers_parent
      subject.should_not include @officers_parent.becomes(Corporation)
    end
  end

  describe "pluck(:id)" do
    subject { Corporation.pluck(:id) }

    it { should include @corporation.id }
    it { should_not include @group.id }
  end

  describe ".corporations_parent" do
    subject { Corporation.corporations_parent }

    it { should be_kind_of Group }
    it { should_not be_kind_of Corporation }
    its(:children) { should include @corporation }
    its(:children) { should_not include @group }
  end

  describe "#is_first_corporation_this_user_has_joined?" do
    before do
      @first_corporation = create( :corporation )
      @second_corporation = create( :corporation )
      @another_corporation = create( :corporation )
      @user = create( :user )

      @first_membership = Membership.create( user: @user, group: @first_corporation )
      @first_membership.valid_from = 1.year.ago
      @first_membership.save

      @second_membership = Membership.create( user: @user, group: @second_corporation )
    end
    describe "for the corporation the user has joined first" do
      subject { @first_corporation.is_first_corporation_this_user_has_joined?( @user ) }
      it { should == true }
    end
    describe "for a corporation the user has not joined first" do
      subject { @second_corporation.is_first_corporation_this_user_has_joined?( @user ) }
      it { should == false }
    end
    describe "for a corporation the user is not even member of" do
      subject { @another_corporation.is_first_corporation_this_user_has_joined?( @user ) }
      it { should == false }
    end
  end

  describe "#status_groups" do
    before do
      @corporation = create( :corporation )

      # status groups are leaf groups of corporations
      @status_group = create( :group )
      @intermediate_group = create( :group )
      @corporation.child_groups << @intermediate_group
      @intermediate_group.child_groups << @status_group

      @another_group = create( :group )
    end
    subject { @corporation.status_groups }

    it "should include the status groups, i.e. the leaf groups of the corporation" do
      subject.should include @status_group
    end
    it "should not include the non-status groups, i.e. the descendant_grous of the corporation that are no leafs" do
      subject.should_not include @intermediate_group
    end
    it "should not include unrelated groups" do
      subject.should_not include @another_group
    end
    describe "after calling admins" do
      before do
        @admins_parent = @status_group.admins_parent
        @officers_parent = @status_group.officers_parent
      end
      it "should still return the correct status groups" do
        subject.should include @status_group
      end
      it "should not return the officers parent groups" do
        subject.should_not include @officers_parent
      end
      it "should not return the admins parent groups such that being admin is not considered a status" do
        subject.should_not include @admins_parent
      end
    end

    specify "the cache should be updated after a status group is renamed" do
      @corporation.status_groups # This created the cached version.
      @status_group.update_attributes name: 'New Status Name'
      subject.reload.map(&:name).should include 'New Status Name'
    end
  end


  describe "#member_table_rows" do
    subject { @corporation.member_table_rows }
    before do
      @corporation = create(:corporation_with_status_groups)
      @corporation.status_groups.last.add_flag :former_members_parent
      @user = create(:user)
      @membership = @corporation.status_groups.first.assign_user @user, at: 1.year.ago
      @former_members_parent = @corporation.former_members_parent
    end

    it "should be an Array of Hashes" do
      subject.should be_kind_of Array
      subject.first.should be_kind_of Hash
    end

    it "should list current members" do
      subject.collect { |row| row[:last_id] }.should_not include @user.id
    end

    it "should not list former members" do
      @membership.promote_to @former_members_parent, at: 10.days.ago

      subject.collect { |row| row[:last_id] }.should_not include @user.id
    end
  end

end
