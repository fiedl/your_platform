# -*- coding: utf-8 -*-
require 'spec_helper'

feature "Relationships on User show view", js: true do

  background do
    @user = create( :user_with_account )
    @related_user = create( :user, first_name: "Jacobus", last_name: "Doe" )
  end

  scenario "adding a relationship and removing it again" do

    visit user_path( @user )
    within( ".section.relationships" ) do

      click_link I18n.t( :edit )
      page.should have_selector( 'a.add_button', visible: true )

      click_on I18n.t( :add )
      page.should have_selector( 'li', count: 2 )

      find( ".best_in_place.relationships.of_by_title * input" )[ :value ].should == @user.title 

      find( ".remove_button" ).click
      page.should have_selector( 'li', count: 1 )

      find( ".save_button" ).click
      page.should_not have_selector( 'a.add_button', visible: true )
      page.should_not have_selector( 'li', visible: true )

    end

  end

  scenario "using the auto completion mechanism for selecting a related user" do
    
    visit user_path( @user )
    within( ".section.relationships" ) do
      click_link I18n.t( :edit )
      click_on I18n.t( :add )
      fill_in 'who_by_title', with: "Jaco"

      # The auto completion mechanism now should suggest the name "Jacobus Doe".
      page.should have_content( "Jacobus Doe" )

      # Clicking on the suggestion should use it in the text field.
      click_on "Jacobus Doe" 
      find( ".best_in_place.relationships.who_by_title input" ).value.should == @related_user.title

    end
    
  end

end

