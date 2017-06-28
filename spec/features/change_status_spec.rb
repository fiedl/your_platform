require 'spec_helper'

feature 'Change Status' do
  include SessionSteps

  before do
    @corporation = create :corporation_with_status_groups
    @user_to_promote = create :user
    @corporation.status_groups.first.assign_user @user_to_promote, at: 1.year.ago
    @local_admin = create :user_with_account
    @corporation.assign_admin @local_admin

    @workflow = @corporation.status_groups.first.child_workflows.first
  end

  specify 'prelims' do
    @workflow.should be_kind_of Workflow
    Ability.new(@local_admin).can?(:execute, @workflow).should be true
    Ability.new(@local_admin).can?(:change_status, @user_to_promote).should be true

    @workflow.steps.first.brick_name.should be_present
    expect { @workflow.execute(user_id: @user_to_promote.id) }.not_to raise_error
  end

  scenario 'promote user from first to second status', js: true do
    login @local_admin
    visit user_path(@user_to_promote)

    within('.box.section.general') do
      find('.workflow_triggers').click
      find('.workflow_trigger').click
    end

    page.should have_no_selector '.workflow_trigger', visible: true
    page.should have_text @user_to_promote.name
    page.should have_selector '.workflow_triggers'

    click_tab :corporate_info_tab
    within("#corporate_vita") { page.should have_text @corporation.status_groups.second.name }

    @user_to_promote.should be_member_of @corporation.status_groups.second
    @user_to_promote.should_not be_member_of @corporation.status_groups.first
  end

  describe "for nested status structures" do
    #
    # corporation
    #      |------ supergroup
    #      |            |------- status1
    #      |
    #      |------ status2
    #
    # When being promoted from status1 to status2, the indirect
    # membership in supergroup should not cause the promotion
    # to be displayed in the workflow menu again.
    # See: https://trello.com/c/yDbXjQMD/1118
    #
    before do
      @supergroup = @corporation.child_groups.create
      @status1 = @corporation.status_groups.first
      @status1.move_to @supergroup
      @workflow.move_to @supergroup

      wait_for_cache
      @user_to_promote.renew_cache
    end

    scenario "promote a user from a group with sub-status groups (bug fix)", js: true do
      login @local_admin
      visit user_path(@user_to_promote)

      within('.box.section.general') do
        find('.workflow_triggers').click
        find('.workflow_trigger').click
      end

      page.should have_no_selector '.workflow_trigger', visible: true
      page.should have_text @user_to_promote.name
      page.should have_selector '.workflow_triggers'

      wait_until(timeout: 90.seconds) { within("#corporate_vita") { page.has_text? @corporation.status_groups.second.name } }

      within("#corporate_vita") { page.should have_text @corporation.status_groups.second.name }

      @user_to_promote.groups(true)
      @user_to_promote.should be_member_of @corporation.status_groups.second
      @user_to_promote.should_not be_member_of @corporation.status_groups.first
    end
  end

end