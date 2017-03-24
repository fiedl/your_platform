require 'spec_helper'

feature "Group Subgroups" do
  include SessionSteps

  background do
    @corporation = create(:corporation)
    @corporations_parent = Group.corporations_parent
    @corporations_parent.add_flag :group_of_groups

    @officer_group = @corporation.create_officer_group name: "Officer of Operations"

    @user = create :user
    @officer_group << @user

    login :user
  end

  specify 'requirements' do
    @corporations_parent.child_groups.should include @corporation
  end

  scenario 'viewing the corporations list and looking up the officers' do
    visit group_subgroups_path(@corporations_parent)
    page.should have_text @officer_group.name
  end

  scenario 'adding an officers group and re-visiting the corporations list' do
    visit group_subgroups_path(@corporations_parent)
    page.should have_text @officer_group.name

    # This should invalidate the cache:
    @another_officers_group = @corporation.create_officer_group name: "Executing Officer"
    @another_officers_group << @user

    visit group_subgroups_path(@corporations_parent)
    page.should have_text @officer_group.name
    page.should have_text @another_officers_group.name
  end

  scenario 'looking up officers of subgroups of corporations' do
    @subgroup = @corporation.child_groups.create name: "Subgroup"
    @another_officers_group = @subgroup.create_officer_group name: "Executing Officer"
    @another_officers_group << @user

    visit group_subgroups_path(@corporations_parent)
    page.should have_text @officer_group.name
    page.should have_text @another_officers_group.name
  end

  scenario 'adding an officer to a subgroup and re-visiting the coporations list' do
    visit group_subgroups_path(@corporations_parent)
    page.should have_text @officer_group.name

    @subgroup = @corporation.child_groups.create name: "Subgroup"

    # This should invalidate the cache:
    @another_officers_group = @subgroup.create_officer_group name: "Executing Officer"
    @another_officers_group << @user

    visit group_subgroups_path(@corporations_parent)
    page.should have_text @officer_group.name
    page.should have_text @another_officers_group.name
  end

end