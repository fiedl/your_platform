require 'spec_helper'

feature "Group of Groups Page" do
  include SessionSteps
  
  background do
    @corporation = create(:corporation)
    @corporations_parent = Group.corporations_parent
    @corporations_parent.add_flag :group_of_groups
    @officer_group = create(:group, name: "Officer of Operations")
    @another_officers_group = create(:group, name: "Executing Officer")
    @user = create :user
    @officer_group << @user
    @another_officers_group << @user

    login :user
  end
  
  specify 'requirements' do
    @corporations_parent.child_groups.should include @corporation
  end
  
  scenario 'viewing the corporations list and looking up the officers' do
    @corporation.officers_parent << @officer_group
    
    visit group_path(@corporations_parent)
    page.should have_text @officer_group.name
  end
  
  scenario 'adding an officers group and re-visiting the corporations list' do
    @corporation.officers_parent << @officer_group
    
    visit group_path(@corporations_parent)
    page.should have_text @officer_group.name
    
    @corporation.officers_parent << @another_officers_group  # This should invalidate the cache.
    
    visit group_path(@corporations_parent)
    page.should have_text @officer_group.name
    page.should have_text @another_officers_group.name
  end
  
  scenario 'looking up officers of subgroups of corporations' do
    @corporation.officers_parent << @officer_group
    @subgroup = @corporation.child_groups.create name: "Subgroup"
    @subgroup.officers_parent << @another_officers_group
    
    visit group_path(@corporations_parent)
    page.should have_text @officer_group.name
    page.should have_text @another_officers_group.name
  end
  
  scenario 'adding an officer to a subgroup and re-visiting the coporations list' do
    @corporation.officers_parent << @officer_group
    
    visit group_path(@corporations_parent)
    page.should have_text @officer_group.name
    
    @subgroup = @corporation.child_groups.create name: "Subgroup"
    @subgroup.officers_parent << @another_officers_group  # This should invalidate the cache.
    
    visit group_path(@corporations_parent)
    page.should have_text @officer_group.name
    page.should have_text @another_officers_group.name
  end
  
end