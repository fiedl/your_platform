require 'spec_helper'

feature "Address changes" do
  include SessionSteps

  background do
    @user = create :user
    @address = @user.profile_fields.create(label: "Study address", type: "ProfileFields::Address")
    @address = ProfileField.find(@address.id)
    @address.first_address_line = "Robert-Blum-Straße 38"
    @address.postal_code = "06114"
    @address.city = "Halle (Saale)"
    @address.country_code = "DE"
    @address.save
  end

  scenario "Prelims" do
    @user.profile_fields.count.should == 2 # email, @address
    @address.children.count.should == 6
  end

  scenario "An admin changes the address of a user", :js do
    login :admin
    visit user_path(@user)
    click_tab :contact_info_tab

    within '.box.contact_information' do
      click_on :edit
      within 'li.profile_field_child.city' do
        fill_in :value, with: "Halle an der Saale"
      end
      click_on :save

      page.should have_no_selector '.save_button'
      page.should have_no_text '...'
      page.should have_text "Robert-Blum-Straße 38"
      page.should have_text "Halle an der Saale"
    end
  end

end