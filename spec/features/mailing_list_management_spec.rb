require 'spec_helper'

feature "Mailing list management" do
  include SessionSteps
  
  scenario "Adding a mailing list", :js do
    @group = create :group
    
    login :admin
    visit group_mailing_lists_path(@group)
    within('.box.mailing_lists') do
      click_on I18n.t(:edit)
      click_on I18n.t(:add)
      fill_in :label, with: 'New Mailing List'
      fill_in :value, with: 'mailinglist@example.com'
      click_on I18n.t(:save)
      
      page.should have_no_selector 'input', visible: true
      page.should have_text 'mailinglist@example.com'
    end

    wait_for_ajax
    @profile_fields = @group.profile_fields.where(type: 'ProfileFields::MailingListEmail')
    @profile_fields.count.should == 1
    @profile_fields.first.label.should == 'New Mailing List'
    @profile_fields.first.value.should == 'mailinglist@example.com'
  end
  
end