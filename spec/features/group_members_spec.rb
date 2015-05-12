require 'spec_helper'

feature "Group Members Page" do
  include SessionSteps

  describe 'when logged in as admin' do
    background do
      @user = create(:user, first_name: "Max", last_name: "Mustermann")
      @group = create(:group)

      login(:admin)
    end
    
    scenario "adding a user as a direct member of the group", :js do
      visit group_members_path(@group)

      fill_autocomplete :user_group_membership_user_title, with: "Max", select: @user.title
      find('.user-select-input').value.should == @user.title
        
      within('.add_group_members') do
        click_on I18n.t(:add)
      end

      within('.box.members') do
        page.should have_text "Mitglieder-Liste wird in wenigen Augenblicken aktualisiert."
      end
        
      # For some reason, turbolinks redirect does not work in this spec.
      # But it works in development and production.
      # 2015-05-12
      #
      # TODO: Remove this manual reload when updating turbolinks.
      visit group_members_path(@group)
        
      within('.box.members') do
        page.should have_text "Mustermann"
        page.should have_text I18n.localize(Date.today)
      end
    end

    scenario "adding a user as a direct member of the group with a date", :js do
      visit group_members_path(@group)

      fill_autocomplete :user_group_membership_user_title, with: "Max", select: @user.title
      find('.user-select-input').value.should == @user.title
        
      within('.add_group_members') do
        fill_in 'user_group_membership[valid_from]', with: '2015-05-08'
        click_on I18n.t(:add)
      end

      within('.box.members') do
        page.should have_text "Mitglieder-Liste wird in wenigen Augenblicken aktualisiert."
      end
        
      # For some reason, turbolinks redirect does not work in this spec.
      # But it works in development and production.
      # 2015-05-12
      #
      # TODO: Remove this manual reload when updating turbolinks.
      visit group_members_path(@group)
        
      within('.box.members') do
        page.should have_text "Mustermann"
        page.should have_text "08.05.2015"
      end
    end

  end
end