module AutoComplete
  
  # Example:
  #
  #     fill_autocomplete :membership_user_title, with: "Max", select: @user.title
  #     find('.user-select-input').value.should == @user.title
  #
  def fill_autocomplete(field, options = {})
    # This method is taken from:
    # https://github.com/joneslee85/ruby-journal-source/blob/master/source/_posts/2013-09-12-how-to-do-jqueryui-autocomplete-with-capybara-2.markdown

    fill_in field, with: options[:with]

    page.execute_script %Q{ $('##{field}').trigger('focus') }
    page.execute_script %Q{ $('##{field}').trigger('keydown') }
    selector = %Q{ul.ui-autocomplete li.ui-menu-item a:contains("#{options[:select]}")}

    page.should have_selector('ul.ui-autocomplete li.ui-menu-item a')
    page.execute_script %Q{ $('#{selector}').trigger('mouseenter').click() }
  end
  
end