require 'spec_helper'

feature "Groups Page" do
  include SessionSteps
  
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
      
      page.should have_selector '#group_members ul.child_users li', count: 1
      page.should have_text @user.title
      find('.user-select-input').value.should == ""
    end
    
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
