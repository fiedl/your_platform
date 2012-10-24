# -*- coding: utf-8 -*-
require 'spec_helper'

feature "Relationships on User show view", js: true do

  background do
    @user = create( :user_with_account )
  end

  scenario "adding a relationship and removing it again" do

    visit user_path( @user )
    within( ".section.relationships" ) do

      click_link I18n.t( :edit )
      page.should have_selector( 'a.add_button', visible: true )

      click_on I18n.t( :add )
      page.should have_selector( 'li', count: 2 )
      find( "input[name=of_by_title]" ).value.should == @user.title

      find( ".remove_button" ).click
      page.should have_selector( 'li', count: 1 )

      find( ".save_button" ).click
      page.should_not have_selector( 'a.add_button', visible: true )
      page.should_not have_selector( 'li', visible: true )

    end

  end

end

