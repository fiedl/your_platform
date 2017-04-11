require 'spec_helper'

feature "Masquerade" do
  include SessionSteps

  scenario "Unpreveliged users (even global admins) should not be able to masquerade" do
    @other_user = create :user_with_account

    login :global_admin
    visit user_masquerade_path(user_id: @other_user.id)

    page.should have_text I18n.t(:access_denied)
  end

end