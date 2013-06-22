module ProfileSteps
  def section_should_be_editable(section, field_types = nil)
    within(".box.section.#{section}") do
      click_on I18n.t(:edit)
      sleep 0.1
      page.should have_selector('a.add_button', visible: true)

      if field_types.kind_of? Array
        field_types.each do |type|
          test_field_type type
        end
      else
        #puts section.to_s + ' with ' + @user.profile_fields.count.to_s

        #expect {click_on I18n.t(:add)}.to change(UserAccount, :count).by 1
        click_on I18n.t(:add)

        page.should have_selector('.profile_field')
        within first '.profile_field' do
          page.should have_selector('input[type=text]')
        end

        find('.remove_button').click
        page.should_not have_selector('.profile_field')
      end

      page.should have_selector('a.save_button', visible: true)
      click_on I18n.t(:save)
    end
  end

  def test_field_type(type)
    #puts type.to_s + ' with ' + @user.profile_fields.count.to_s
    click_on I18n.t(:add)
    sleep 0.1

    expect {
      field_name = type.name.demodulize.underscore
      page.should have_selector("a#add_#{field_name}_field")
      click_on I18n.t(field_name)
      sleep 0.5
    }.to change(UserAccount, :count).by 1

    page.should have_selector('.profile_field')

    page.should have_selector('.remove_button')

    expect {
      find('.remove_button').click
      sleep 0.1
    }.to change(UserAccount, :count).by -1
    #how to test if removing the field worked?


    click_on I18n.t(:add) #Temporary, this is needed to close the combobox of the add button.
  end
end
