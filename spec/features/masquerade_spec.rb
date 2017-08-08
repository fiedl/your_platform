require 'spec_helper'

feature "Masquerade" do
  include SessionSteps

  scenario "Unpreveliged users (even global admins) should not be able to masquerade" do
    @other_user = create :user_with_account

    login :global_admin
    visit user_masquerade_path(user_id: @other_user.id)

    page.should have_text I18n.t(:access_denied)
  end

  scenario "Bypassing the authorization by visiting the masquerade path directly is prevented" do
    @other_user = create :user_with_account, last_name: "other user"

    login :global_admin
    visit "/user_accounts/masquerade/#{@other_user.account.id}"

    page.should have_text I18n.t(:access_denied)
  end

  scenario "developers who are global admins can masquerade as other users" do
    @developer = create :user_with_account
    @developer.global_admin = true
    @developer.developer = true
    @other_user = create :user_with_account

    login @developer
    visit user_masquerade_path(user_id: @other_user.id)

    page.should have_text t(:you_are_masquerading_as_str, str: @other_user.title)
  end

end