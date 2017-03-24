require 'spec_helper'

feature "memberships#index" do
  include SessionSteps

  let(:group) { create :group }
  let(:user) { create :user }

  background do
    group.assign_user user
  end

  scenario "viewing the memberships of the groups as global admin" do
    login :global_admin
    visit memberships_path(group_id: group.id)

    page.should have_text user.last_name
  end

  scenario "viewing the memberships of the user as global admin" do
    login :global_admin
    visit memberships_path(user_id: user.id)

    page.should have_text group.name
  end

end