require 'spec_helper'

# For the moment, this file is a double-check. For the main tests, see the controller
# specs of the groups controller.
#
feature 'Group Member List Export' do
  include SessionSteps

  before do
    @group = create :group, :with_members

    login :admin
  end

  scenario 'exporting a birthday list as csv' do
    visit group_list_export_path group_id: @group.id, list: 'birthday_list', format: 'csv'
    page.should have_text @group.members.first.last_name
  end
end