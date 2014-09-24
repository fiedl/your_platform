require 'spec_helper'

feature "Groups Page" do
  include SessionSteps


  describe 'when logged in as admin' do
    background do
      @user = create(:user, first_name: "Max", last_name: "Mustermann")
      @group = create(:group)

      login(:admin)
    end

    scenario "adding a user as a direct member of the group", :js do
      visit group_path(@group)

      within('.box.section.members') do
        click_on I18n.t(:edit)
      end

      fill_autocomplete :user_group_membership_user_title, with: "Max", select: @user.title
      find('.user-select-input').value.should == @user.title

      within('.box.section.members') do
        click_on I18n.t(:add)

        page.should have_selector '#group_members .new_child_users li', count: 1
        page.should have_text @user.title
        find('.user-select-input').value.should == ""
      end

      # Pressing enter in the blank text field should close the edit mode.
      # But since a poltergeist update, apparently, pressing enter in the blank text field does not
      # trigger the form submission anymore. Instead, we'll hit the submit button here.
      #
      # press_enter in: 'user_group_membership_user_title'
      click_button I18n.t(:add)

      page.should have_no_selector '#user_group_membership_user_title', visible: true

    end

    def fill_autocomplete(field, options = {})
      # This method is taken from:
      # https://github.com/joneslee85/ruby-journal-source/blob/master/source/_posts/2013-09-12-how-to-do-jqueryui-autocomplete-with-capybara-2.markdown

      fill_in field, with: options[:with]

      page.execute_script %Q{ $('##{field}').trigger('focus') }
      page.execute_script %Q{ $('##{field}').trigger('keydown') }
      selector = %Q{ul.ui-autocomplete li.ui-menu-item a:contains("#{options[:select]}")}

      page.should have_selector('ul.ui-autocomplete li.ui-menu-item a')
      page.execute_script %Q{ $('#{selector}').trigger('mouseenter').click() }
    end

  end

  describe 'when logged in as regular user' do
    background do
      @group = create(:group, :with_members, :with_hidden_member, :with_dead_member)
      login(:user)
    end

    scenario 'should not render list entries for hidden members' do
      visit group_path(@group)
      page.should have_selector '#group_members tr', count: 12
      page.should have_no_text 'Hidden'
    end
    
    scenario 'should render list entries for dead members' do
      visit group_path(@group)
      page.should have_selector '#group_members tr', count: 12
      page.should have_text 'Dead'
    end
  end
  
end
