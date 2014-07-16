require 'spec_helper'
require 'cancan/matchers'

# In order to call the user "he" rather than "it", 
# we have to define an alias here.
# 
# http://stackoverflow.com/questions/12317558/alias-it-in-rspec
#
RSpec.configure do |c|
  c.alias_example_to :he
end

describe "User: abilities" do
  
  # I'm sorry. I do have problems with cancan's terminology, here.
  # For me, the User can do something, i.e. I would ask 
  #
  #   @user.can? :manage, @page
  #
  # But for cancan, it's 
  #
  #   Ability.new(@user).can? :manage, @page
  #
  # That is why I let(:the_user) be the ability.
  # Also note, "he" refers to the regular "it" call.
  # I just like to call the user "he" rather than "it".
  #  
  let(:user) { create(:user_with_account) }
  let(:ability) { Ability.new(user) }
  subject { ability }
  let(:the_user) { subject }
  
  context "when the user is a global admin" do
    before { user.global_admin = true }
    he "should be able to manage everything" do
      @page = create(:page)
      the_user.should be_able_to :manage, @page
      @group = create(:group)
      the_user.should be_able_to :manage, @group
      @other_user = create(:user)
      the_user.should be_able_to :manage, @other_user
    end
  end
  
  he "should be able to edit his own profile fields" do
    @profile_field = user.profile_fields.create(type: "ProfileFieldTypes::Phone", value: "123-456789")

    the_user.should be_able_to :create, ProfileField.new
    the_user.should be_able_to :read, @profile_field
    the_user.should be_able_to :update, @profile_field
    the_user.should be_able_to :destroy, @profile_field
    the_user.should_not be_able_to :manage, @profile_field
  end
  context 'when the user is in a group' do
    before do
      @group = create(:group)
      @group.members << user
    end
    he 'should be able to edit his own user group membership dates' do
      the_user.should be_able_to :update, UserGroupMembership.find_by_user_and_group(user, @group)
    end
  end
  he "should be able to read anything (exceptions are below)" do
    @page = create(:page)
    the_user.should be_able_to :read, @page
    @group = create(:group)
    the_user.should be_able_to :read, @group
    @other_user = create(:user)
    the_user.should be_able_to :read, @other_user
  end
  he "should be able to download anything" do
    @attachment = Attachment.new
    the_user.should be_able_to :download, @attachment
  end
  he "should not be able to read the bank account information of other users" do
    @other_user = create(:user)
    @bank_account_of_other_user = @other_user.profile_fields.create(type: 'ProfileFieldTypes::BankAccount')
    the_user.should_not be_able_to :read, @bank_account_of_other_user
  end
  he "should be able to read the bank account information of groups" do
    @group = create(:group)
    @bank_account_of_group = @group.profile_fields.create(type: 'ProfileFieldTypes::BankAccount')
    the_user.should be_able_to :read, @bank_account_of_group
  end
  he "should not be able to see the temporary activity log." do
    PublicActivity::Activity.create
    
    the_user.should_not be_able_to :read, PublicActivity::Activity
    the_user.should_not be_able_to :read, PublicActivity::Activity.first
  end
  he "should not be able to export the member list" do
    the_user.should_not be_able_to :export_member_list, @group
  end 
  
  describe "if other users are hidden" do
    before do
      @hidden_user = create(:user)
      @hidden_user.hidden = true
    end
    he "should not be able to see the hidden users" do
      the_user.should_not be_able_to :read, @hidden_user
    end
  end
  describe "if the user is hidden himself" do
    before { user.hidden = true}
    he "should be able to read himself" do
      user.hidden.should == true
      the_user.should be_able_to :read, user
    end
  end
  
  
  context "when the user is a local admin" do
    before do
      @group = create(:group)
      @group.admins << user
    end
    he "should be able to manage the group he is admin of" do
      the_user.should be_able_to :manage, @group
    end
    he "should be able to manage the users in the group he is admin of" do
      @other_user = create(:user)
      @group.assign_user @other_user
      the_user.should be_able_to :manage, @other_user
    end
    he "should be able to manage the users' profile fields" do
      @other_user = create(:user)
      @group.assign_user @other_user
      @profile_field = @other_user.profile_fields.create(label: "Home Address", type: 'ProfileFieldTypes::Address')
      the_user.should be_able_to :manage, @profile_field
    end
    he "should be able to update the user's structured profile fields" do
      @other_user = create(:user)
      @group.assign_user @other_user
      @profile_field = @other_user.profile_fields.create(label: "Bank Account", type: 'ProfileFieldTypes::BankAccount').becomes(ProfileFieldTypes::BankAccount)
      @profile_field.account_holder = "John Doe"
      @child_profile_field = @profile_field.children.first
      the_user.should be_able_to :update, @child_profile_field
    end
    he "should be able to manage subgroups" do
      @subgroup = create(:group)
      @subgroup.parent_groups << @group
      the_user.should be_able_to :manage, @subgroup
    end
    he "should be able to manage users of subgroups" do
      @subgroup = create(:group)
      @subgroup.parent_groups << @group
      @other_user = create(:user)
      @subgroup.assign_user @other_user
      the_user.should be_able_to :manage, @other_user
    end
    he "should be able to execute workflows of his group" do
      @workflow = create(:workflow)
      @workflow.parent_groups << @group
      the_user.should be_able_to :execute, @workflow
    end
    he "should not be able to manage unrelated groups or users" do
      @other_group = create(:group)
      the_user.should_not be_able_to :manage, @other_group
      @other_user = create(:user)
      the_user.should_not be_able_to :manage, @other_user
    end
  end

  context "when the user is a local admin of a page" do
    before do
      @page = create(:page)
      @page.admins << user
    end
    he "should be able to manage this page" do
      the_user.should be_able_to :manage, @page
    end
    he "should be able to manage subgroups of this page" do
      @subgroup = @page.child_groups.create
      the_user.should be_able_to :manage, @subgroup
    end
    he "should NOT be able to manage descendant users" do
      @subgroup = @page.child_groups.create
      @other_user = create(:user)
      @subgroup << @other_user 
      the_user.should_not be_able_to :update, @other_user
    end
  end
  
  context "when the user is officer of a group" do
    before do
      @group = create :group
      @officer_group = @group.officers_groups.create(name: "Secretary")
      @officer_group.assign_user user
    end
    he "should be able to export the member list" do
      the_user.should be_able_to :export_member_list, @group
    end 
  end
end
  
