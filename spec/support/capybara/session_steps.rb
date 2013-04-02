module SessionSteps
  def login(user = nil)
    user = create(:user_with_account) unless user

    password = user.account.password
    login_string = user.alias

    visit new_user_account_session_path
    fill_in 'user_account_login', with: login_string
    fill_in 'user_account_password', with: password
    click_button I18n.t( :login )
  end

  def logout
    click_link I18n.t( :logout )
  end

end
