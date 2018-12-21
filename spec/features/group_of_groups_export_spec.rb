require 'spec_helper'

feature "Group-of-groups Export" do

  scenario "exporting a csv list for a group of groups" do
    @group_of_groups = create :group, type: "Groups::GroupOfGroups", name: "Group of Groups"
    @group_of_groups = Group.find @group_of_groups.id
    @child_group = create(:group, name: "Child Group"); @group_of_groups << @child_group

    login :admin
    visit group_path @group_of_groups

    click_on :download
    click_on :csv_list

    page.should have_no_text "Group of Groups"
    page.should have_text "Child Group"
  end

end