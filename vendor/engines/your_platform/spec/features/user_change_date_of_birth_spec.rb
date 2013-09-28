# -*- coding: utf-8 -*-
require 'spec_helper'

feature "Change date of birth" do
  include SessionSteps

  background do
    @user = create(:user_with_account)
    login @user
  end
#  scenario "visit user page and change date of birth" do
#    visit user_path(@user)
#    first("dd.date_of_birth").click
#
#    within() do
#      find(".best_in_place").click
#      sleep 7
#      #page.should have_selector("input")
#      save_and_open_page
#      fill_in :date_of_birth, :with => I18n.localize("1980-01-01".to_date)
#      page.should have_text(I18n.localize("1980-01-01".to_date))
#      @user.date_of_birth.should have_content(I18n.localize("1980-01-01".to_date))
#    end
#  end

end
