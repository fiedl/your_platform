# -*- coding: utf-8 -*-
require 'spec_helper'

feature "Change date of birth" do
  include SessionSteps

  background do
    @user = create( :user_with_account )
    login @user
  end
  scenario "visit user page and change date of birth" do
    visit user_path(@user)
    within("dd.date_of_birth") do
      find(".best_in_place").set(I18n.localize("1980-01-01".to_date))
      @user.date_of_birth.to_date.should have_content(I18n.localize("1980-01-01".to_date))
    end

  end
end
