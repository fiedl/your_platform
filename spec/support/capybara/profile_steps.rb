module ProfileSteps
  def section_should_be_editable(section, field_types = nil)
    within(".box.section.#{section}") do
      click_on I18n.t(:edit)
      wait_for_ajax; wait_for_ajax

      page.should have_selector('a.add_button', visible: true)

      if field_types.kind_of? Array
        field_types.each do |type|
          test_field_type type
        end
      else
        expect{
          click_on I18n.t(:add)
          page.should have_selector('.profile_field_parent', visible: true)
        }.to change{ all('.profile_field_parent').count }.by 1

        within first '.profile_field' do
          page.should have_selector('input[type=text]', visible: true)
        end

        expect{
          click_on I18n.t(:remove)
          page.should have_no_selector('.profile_field_parent', visible: true)
          wait_for_ajax
        }.to change{ all('.profile_field_parent').count }.by -1
      end

      page.should have_selector('a.save_button', visible: true)
      page.find('.save_button').trigger :click
    end
  end

  def test_field_type(type)
    #puts type.to_s + ' with ' + @user.profile_fields.count.to_s
    field_name = type.name.demodulize.underscore
    #page.save_screenshot('tmp/screenshot1.png')
    page.should have_selector('.add_button', visible: true)
    page.find('.add_button').trigger :click   # click_on I18n.t(:add)
    wait_for_ajax; wait_for_ajax
    #page.save_screenshot('tmp/screenshot2.png')

    expect {
      #page.should have_selector("a#add_#{field_name}_field", visible: true)
      #puts all('.profile_field_parent').count.to_s + ' profile fields'

      page.should have_content(I18n.t(field_name))
      #page.save_screenshot('tmp/screenshot3.png')
      click_on I18n.t(field_name)
      wait_for_ajax; wait_for_ajax
      #page.save_screenshot('tmp/screenshot4.png')
      page.should have_no_selector("a#add_#{field_name}_field", visible: true)
      #puts all('.profile_field_parent').count.to_s + ' profile fields'
    }.to change{ all('.profile_field_parent').count }.by 1

    expect {
      within (all('.profile_field_parent').last) do
        page.should have_selector('.remove_button', visible: true)
        page.find('.remove_button').trigger :click  # the button has no size in the spec
      end
    
      page.should have_no_selector("a#add_#{field_name}_field", visible: true)
      page.should have_selector('ul.profile_fields')
      
      # p "============================================================================", type
      wait_for_ajax
      # puts all('.remove_button').count.to_s + ' remove buttons'
      # puts all('.profile_field_parent', visible: true).count.to_s + ' profile fields'
    }.to change{ all('.profile_field_parent').count }.by -1 
  end
  
end
