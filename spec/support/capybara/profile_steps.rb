module ProfileSteps
  def section_should_be_editable(section, field_types = nil)
    within(".box.section.#{section}") do
      click_on I18n.t(:edit)

      page.should have_selector('a.add_button', visible: true)

      if field_types.kind_of? Array
        field_types.each do |type|
          test_field_type type
        end
      else
        expect{
          click_on I18n.t(:add)
          page.should have_selector('.profile_field', visible: true)
        }.to change{ all('.profile_field').count }

        within first '.profile_field' do
          page.should have_selector('input[type=text]')
        end

        expect{
          find('.remove_button').click
          page.should have_no_selector('.profile_field')
        }.to change{ all('.profile_field').count }

      end

      page.should have_selector('a.save_button', visible: true)
      click_on I18n.t(:save)
    end
  end

  def test_field_type(type)
    #puts type.to_s + ' with ' + @user.profile_fields.count.to_s
    click_on I18n.t(:add)

    puts all('.profile_field').count.to_s + ' profile fields'
    expect {
      field_name = type.name.demodulize.underscore
      page.should have_selector("a#add_#{field_name}_field", visible: true)

      page.should have_content(I18n.t(field_name))
      click_on I18n.t(field_name)
      page.should have_no_selector("a#add_#{field_name}_field", visible: true)
      puts all('.profile_field').count.to_s + ' profile fields'
    }.to change{ all('.profile_field').count }

    page.should have_selector('.profile_field')

    page.should have_selector('.remove_button')

    #expect {
      all('.remove_button').last.click
      puts all('.remove_button').count.to_s + ' remove buttons'
      page.should have_no_selector('this_is_just_to_trigger_capybaras_ajax_awaiting_which_is_not_triggered_by_click')
      puts all('.profile_field').count.to_s + ' profile fields'
    #}.to change{ all('.profile_field').count }
  end
end
