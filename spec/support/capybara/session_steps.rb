module SessionSteps

  # This helper method allows to simulate the login of a given user.
  #
  # If the +parameter+ specifies a +User*, this user is logged in.
  # If the +parameter+ specifies a +:role+, a user with this role is created and logged in.
  # If +parameter+ is nil, a new user is created and logged in.
  #
  # Local admins:
  #   login :local_admin, of: @group
  #
  def login(parameter = nil, args = {})
    if parameter == :local_admin && args[:of] == nil
      raise 'Please specify the object to administrate:  login(:local_admin, of: @group)'
    end
    if parameter.kind_of?(Symbol) and not parameter.in?([:user, :local_admin, :global_admin, :admin])
      raise "Unknown login parameter: #{parameter}"
    end

    user = parameter if parameter.kind_of? User
    user = create(:admin) if parameter == :admin or parameter == :global_admin
    user = create(:local_admin, of: args[:of]) if parameter == :local_admin
    user = create(:user_with_account) if parameter == :user
    user ||= create(:user_with_account)

    user.accept_terms(TermsOfUseController.new.current_terms_stamp) unless args[:accepted_terms] == false

    password = user.account.password
    login_string = user.alias

    visit sign_in_path
    confirm_cookies_notice

    within "#content" do
      fill_in 'user_account_login', with: login_string
      fill_in 'user_account_password', with: password
      click_button I18n.t(:login)
    end

    page.should have_no_text I18n.t(:login)
  end

  def accept_terms_of_use
    if page.has_text? I18n.t(:terms_of_use)
      check :accept
      click_on I18n.t(:confirm)
    end
    page.should have_no_selector '.terms_of_use'
  end

  def logout
    click_link I18n.t( :logout )
  end

  def confirm_cookies_notice
    if page.has_selector? ".cc-window"
      within ".cc-window" do
        find(".cc-btn.cc-dismiss").click
      end
    end
  end

end
