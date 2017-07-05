module HomePageSpecHelper
  def create_a_new_blog_post(title, options = {})
    click_on :new_page

    fill_in :page_title, with: title
    choose :type_blog_post
    click_on :confirm
  end

  def create_a_new_teaser_box(title, options = {})
    click_on :new_page

    fill_in :page_title, with: title
    choose :type_page
    check :display_the_new_page_as_teaser_box
    uncheck :display_the_new_page_in_the_nav

    click_on :confirm

    within('.box_header') { page.should have_text title }
  end

  def create_a_new_menu_item(title, options = {})
    click_on :new_page

    fill_in :page_title, with: title
    choose :type_page
    uncheck :display_the_new_page_as_teaser_box
    check :display_the_new_page_in_the_nav

    click_on :confirm
  end

  def edit_page_content(text)
    page.should have_selector ".page_body .wysiwyg"
    edit_wysiwyg ".page_body .wysiwyg", text
  end
end