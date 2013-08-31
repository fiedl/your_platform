module SessionSteps

  # This helper method allows to simulate the login of a given user.
  # 
  # If the +parameter+ specifies a +User*, this user is logged in.
  # If the +parameter+ specifies a +:role+, a user with this role is created and logged in.
  # If +parameter+ is nil, a new user is created and logged in.
  #
  def login( parameter = nil)

    user = parameter if parameter.kind_of? User
    user = create(:admin) if parameter == :admin
    user = create(:user_with_account) if parameter == :user
    user ||= create(:user_with_account)

    password = user.account.password
    login_string = user.alias

    visit sign_in_path
    within "#content_area" do
      fill_in 'user_account_login', with: login_string
      fill_in 'user_account_password', with: password
      click_button I18n.t( :login )
    end
  end

  def logout
    click_link I18n.t( :logout )
  end

end
