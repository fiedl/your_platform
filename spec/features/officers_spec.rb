require 'spec_helper'
include SessionSteps

feature "Officers Management" do

  background do
    @group = create(:group)
    @user = create(:user)
    @president_group = @group.officers_parent.child_groups.create(name: "President"); @president_group.update_attribute(:type, 'OfficerGroup')
    @president_group << @user
  end

  scenario "visiting a group site and looking at the officers" do
    login(:user)
    visit group_path(@group)
    within('.group_tabs') { click_on I18n.t(:officers) }

    within(".box.officers") do
      page.should have_text "President"
      page.should have_text @user.title
    end
  end

  describe "officers of subgroups: " do
    background do
      @subgroup = @group.child_groups.create
      @ceo_group = @subgroup.officers_parent.child_groups.create(name: "CEO")
      @ceo_group.update_attribute(:type, 'OfficerGroup')
      @ceo_group << @user
    end

    scenario "visiting the group page and looking at the officers" do
      login(:user)
      visit group_path(@group)
      within('.group_tabs') { click_on I18n.t(:officers) }

      within(".box.officers") do
        page.should have_text "President"
        page.should have_text "CEO"
      end
    end
  end

  scenario "assigning an officer", :js => true do
    login(:admin)
    visit group_path(@group)
    within('.group_tabs') { click_on I18n.t(:officers) }

    @new_user = create(:user)

    within(".box.officers") do
      page.should have_text "President"
      page.should have_text @user.title

      within(".box_header") { click_on I18n.t(:edit) }
      fill_in "direct_members_titles_string", with: @new_user.title
      find(".save_button").click
    end

    wait_until(timeout: 45.seconds) { @president_group.members.reload.include? @new_user }

    within(".officer_group_members .direct_officers .best_in_place") do
      page.should have_selector "a", text: @new_user.title
    end

    @group.officers_parent.child_groups.where(name: "President").first.members.should include @new_user
    @group.officers_parent.child_groups.where(name: "President").first.members.should_not include @user
  end

end
