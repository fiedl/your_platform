require 'spec_helper'

feature 'Mark user as deceased' do
  include SessionSteps
  
  before do
    @user = create :user
    @corporation = create :corporation
    @corporation.child_groups.create(name: "Philisterschaft") # triggers creation of sub groups.
    @philister = @corporation.status_group("Philister")
    @verstorbene = @corporation.child_groups.create(name: "Verstorbene")
    @membership = @philister.assign_user @user, at: 1.day.ago
    Workflow.find_or_create_mark_as_deceased_workflow
    @user.reload

    login :admin
  end
  
  specify 'prelims' do
    @user.current_status_group_in(@corporation).should == @philister
    @user.current_status_membership_in(@corporation).should == @membership.becomes(StatusGroupMembership)
  end
  
  scenario 'mark the user as deceased', js: true do
    visit user_path(@user)
    
    within('.box.section.general') do
      find('.workflow_triggers').click
      find('.deceased_trigger').click
    end
      
    localized_date = I18n.localize("2014-07-06".to_date)
    within('.deceased_modal_date_of_death') do
      fill_in 'localized_date_of_death', with: localized_date
      click_on I18n.t(:confirm)
    end
    
    page.should have_text @user.reload.title
    page.should have_text "(✟)"
    page.should have_text localized_date
    @user.current_status_group_in(@corporation).should == @verstorbene
    
    visit group_path(@verstorbene)
    page.should have_text @user.last_name
  end
end