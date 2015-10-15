class PublicRootController < ApplicationController
  
  def index
    @page = Page.public_root
    authorize! :read, @page
    
    @public_root_element_pages = Page.flagged(:public_root_element)
    
    @events = Event.where(publish_on_global_website: true)
      .upcoming.order('events.start_at, events.created_at')
      .limit(5)
      
    @hide_attachment_drop_fields = false
    
    set_current_navable @page
    set_current_activity :looks_at_the_start_page, @page
    set_current_access :public
    set_current_access_text :this_is_the_public_website_and_can_be_read_by_all_internet_users
  end
  
end
