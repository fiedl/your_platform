module ControllerMacros
  def login_admin
    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:admin]
      sign_in FactoryGirl.create(:admin, :accepted_terms_of_use).account
    end
  end

  def login_user
    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in FactoryGirl.create(:user_with_account, :accepted_terms_of_use).account
    end
  end
end

RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
end
