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

describe Ability do
  
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
  
  
  # 
  # Regular Users
  # 
    
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
  he "should be able to update his account, e.g. his password" do
    the_user.should be_able_to :update, user.account
  end
  he "should not be able to create an account" do
    the_user.should_not be_able_to :create, UserAccount
  end
  he "should not be able to destroy his account" do
    the_user.should_not be_able_to :destroy, user.account
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
  
  context "(reading pages and documents)" do
    before do
      @group = create(:group)
      @page_of_group = @group.child_pages.create name: "This page belongs to the group."
      @attachment_of_group = @page_of_group.attachments.create description: "This attachments belongs to the group."
      @subpage_of_group = @page_of_group.child_pages.create name: "This subpage belongs to the group."
      @subpage_attachment_of_group = @subpage_of_group.attachments.create description: "This attachments belongs to the group."
      @subgroup = @group.child_groups.create name: "Subgroup"
      @page_of_subgroup = @subgroup.child_pages.create name: "This page belongs to the subgroup."
      @attachment_of_subgroup = @page_of_subgroup.attachments.create description: "This attachments belongs to the subgroup."
    end
    context "when the user is not member of a group" do
      he { should_not be_able_to :read, @page_of_group }
      he { should_not be_able_to :download, @attachment_of_group }
    end
    context "when the user is member of a group, but not of a subgroup" do
      before { @group.assign_user user, at: 1.hour.ago }
      he { should be_able_to :read, @page_of_group }
      he { should be_able_to :read, @subpage_of_group }
      he { should_not be_able_to :read, @page_of_subgroup }
      he { should be_able_to :download, @attachment_of_group }
      he { should be_able_to :download, @subpage_attachment_of_group }
      he { should_not be_able_to :download, @attachment_of_subgroup }
      context "when another link is created later (this avoids ancestor_groups.last in Page#group)" do
        before { @page_of_group.parent_groups.create name: "Another group" }
        he { should be_able_to :read, @page_of_group }
        he { should be_able_to :read, @subpage_of_group }
        he { should_not be_able_to :read, @page_of_subgroup }
        he { should be_able_to :download, @attachment_of_group }
        he { should be_able_to :download, @subpage_attachment_of_group }
        he { should_not be_able_to :download, @attachment_of_subgroup }
      end
    end
    context "when the user is member of a subgroup (ergo also of the group)" do
      before { @subgroup.assign_user user, at: 1.hour.ago }
      he { should be_able_to :read, @page_of_group }
      he { should be_able_to :read, @subpage_of_group }
      he { should be_able_to :read, @page_of_subgroup }
      he { should be_able_to :download, @attachment_of_group }
      he { should be_able_to :download, @subpage_attachment_of_group }
      he { should be_able_to :download, @attachment_of_subgroup }
    end
    context "when the page does not have a group associated" do
      before { @page_without_group = create :page }
      he { should be_able_to :read, @page_without_group }
    end
  end
  
  context "(joining events)" do
    before do
      @group = create :group
      @event = @group.child_events.create
    end
    he { should be_able_to :read, @event }
    he { should be_able_to :join, @event }
    he { should be_able_to :leave, @event }
    he { should_not be_able_to :create_event, @group }
    he { should be_able_to :index_events, user }
    he { should_not be_able_to :index_event, create(:user) }
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
    before do
      user.hidden = true
    end
    he "should be able to read himself" do
      user.hidden.should == true
      the_user.should be_able_to :read, user
    end
  end

  describe "(auto-completion)" do
    he "should be able to use a name-auto-complete list" do
      the_user.should be_able_to :autocomplete_title, User
    end
    specify "users without account should not be able to use the name-auto-complete list" do
      Ability.new(nil).should_not be_able_to :autocomplete_title, User
    end
  end
  
  #
  # Officers
  #
  
  context "when the user is officer of a group" do
    before do
      @group = create :group
      @officer_group = @group.officers_groups.create(name: "Secretary")
      @officer_group.assign_user user
      @sub_group = @group.child_groups.create(name: "Sub Group")
      @sub_sub_group = @sub_group.child_groups.create(name: "Sub Sub Group")
      @parent_group = @group.parent_groups.create(name: "Parent Group")
    end
    he "should be able to export the member list" do
      the_user.should be_able_to :export_member_list, @group
    end
    he "should be able to export the member lists of the sub groups" do
      the_user.should be_able_to :export_member_list, @sub_group
    end
    he "should be able to export the member list fo the sub sub group" do
      the_user.should be_able_to :export_member_list, @sub_sub_group
    end
    he "should not be able to export the member list of parent groups" do
      the_user.should_not be_able_to :export_member_list, @parent_group
    end

    he "should be able to create an event in his group" do
      the_user.should be_able_to :create_event, @group
    end
    he "should be able to update events in his group" do
      @event = @group.child_events.create
      the_user.should be_able_to :update, @event
    end
    he "should be able to create events in subgroups of his group" do
      the_user.should be_able_to :create_event, @sub_group
    end
    he "should be able to update events in subgroups of his group" do
      @event = @sub_group.child_events.create
      the_user.should be_able_to :update, @event
    end
    he "should be able to update events in sub sub groups of his group" do
      @event = @sub_sub_group.child_events.create
      the_user.should be_able_to :update, @event
    end
    he "should be able to update the contact people of an event" do
      @event = @group.child_events.create
      the_user.should be_able_to :update, @event.contact_people_group
    end
  end
  
  #
  # Local page admins
  #
  
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
    
  #
  # Local group admins
  #
    
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
    he "should be able to manage the profile fields of the group" do
      @profile_field = @group.profile_fields.create(label: "Bank Account", type: 'ProfileFieldTypes::BankAccount').becomes(ProfileFieldTypes::BankAccount)
      the_user.should be_able_to :manage, @profile_field
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
    he "should be able to execute the mark_as_deceased workflow, which is a global workflow" do
      @workflow = Workflow.find_or_create_mark_as_deceased_workflow
      the_user.should be_able_to :execute, @workflow
    end
    he "should not be able to manage unrelated groups or users" do
      @other_group = create(:group)
      the_user.should_not be_able_to :manage, @other_group
      @other_user = create(:user)
      the_user.should_not be_able_to :manage, @other_user
    end
    he "should be able to manage the group's users' memberships" do
      @other_user = create(:user)
      @membership = @group.assign_user @other_user
      the_user.should be_able_to :manage, @membership
    end
    he "should not be able to rename admin groups" do
      @admins_group = @group.admins_parent
      the_user.should_not be_able_to :rename, @admins_group
    end
    he "should be able to rename a regular subgroup" do
      @subgroup = @group.child_groups.create
      the_user.should be_able_to :rename, @subgroup
    end
    he "should be able to assign and unassign members of the group and regular subgroups" do
      @subgroup = @group.child_groups.create
      the_user.should be_able_to :update_memberships, @subgroup
      the_user.should be_able_to :update_memberships, @group
    end
    he "should not be able to assign and unassign admins" do
      @admins_group = @group.admins_parent
      @subgroup = @group.child_groups.create
      @subgroup_admins_group = @subgroup.admins_parent
      the_user.should_not be_able_to :update_memberships, @admins_group
      the_user.should_not be_able_to :update_memberships, @subgroup_admins_group
    end
  end

  # 
  # Global Admins
  #
  
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
    specify "turning the switch on and off should change the abilities accordingly and not cause caching issues" do
      @page = create(:page)
      the_user.should be_able_to :manage, @page
      
      user.global_admin = false
      wait_for_cache
      Ability.new(User.find user.id).should_not be_able_to :manage, @page
      
      user.global_admin = true
      wait_for_cache
      Ability.new(User.find user.id).should be_able_to :manage, @page
    end
  end
  
end
  
