require 'spec_helper'

feature 'Mark user as deceased' do

  before do
    @corporation = create :corporation_with_status_groups
    @status1 = @corporation.status_groups.first
    @deceased = @corporation.child_groups.create name: 'Deceased', type: 'StatusGroup'
    @user = create :user_with_account
    @status1.assign_user @user, at: 1.year.ago
    @workflow = Workflow.find_or_create_mark_as_deceased_workflow
  end

  scenario 'mark the user as deceased', :js do
    login :admin

    visit user_path(@user)
    within('.box.general') { page.should have_selector '.workflow_triggers' }
    click_tab :corporate_info_tab
    within('.box.corporate_vita') { page.should have_selector '.workflow_triggers' }

    within '.box.corporate_vita' do
      find('.workflow_triggers').click
      find('.deceased_trigger').click
    end

    localized_date = I18n.localize 1.day.ago.to_date
    within '.deceased_modal_date_of_death' do
      fill_in 'localized_date_of_death', with: localized_date
      click_on :confirm
    end

    within '.box.corporate_vita' do
      page.should have_text localized_date
    end

    visit user_path(@user)
    page.should have_text "(✟)"

    click_tab :more_info_tab
    page.should have_text t(:user_has_no_account)

    visit group_members_path(group_id: @deceased.id)
    page.should have_text @user.last_name
  end

end