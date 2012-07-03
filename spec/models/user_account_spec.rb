# -*- coding: utf-8 -*-
require 'spec_helper'

describe UserAccount do
  
  before do
    @user = User.new( first_name: "Max", last_name: "Mustermann", alias: "m.mustermann",
                      email: "max.mustermann@example.com", create_account: true )
    @user_account = @user.account
  end

  subject { @user_account }

  it { should respond_to :password_digest }
  it { should respond_to :authenticate }

end
