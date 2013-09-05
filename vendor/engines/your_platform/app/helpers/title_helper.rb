#
# Each displayed html page has got a header title tag, i.e. <html><head><title>...</title></head>...</html>.
# For a typical page, the title should be something like this: "User 'doe' - YourAppName", where the 
# first part depends on the currently shown page, the second part just contains your app's name. 
# If no first part exists, just display the app's name.
# 
# The first part of the title, i.e. the part specific to the currently shown page, 
# is set in the html view of the currently shown page, since it is only required for html responses.
# 
#    <!-- In the view, e.g. app/views/users/show.html.erb: -->
#    <% set_title("User '#{@user.alias}'") %>
#
# In the layout, the full title can be refered to as `website_title_with_app_name`.
# 
#    <!-- In the layout, e.g. app/views/layouts/application.html.erb: -->
#    <head><title><%= website_title_with_app_name %></title>...</head>
#
# This behaviour is mostly inspired by Micheal Hartl's rails tutorial:
#
#   https://github.com/mhartl/sample_app/tree/master/app/views
#   http://ruby.railstutorial.org/ruby-on-rails-tutorial-book
#
module TitleHelper
  
  def set_title( title )
    set_website_title(title)
  end
  def set_website_title( title )
    provide(:title, title)
  end
  
  def website_title_set_by_controller
    # yield(:title) uses the new mechanism.
    # @title uses the old mechanism.
    # TODO: Remove @title when it is not used in the controllers anymore.
    #
    content_for(:title) || @title
  end
  
  def website_title_with_app_name
    if website_title_set_by_controller.present? 
      if website_title_set_by_controller.include?(application_name)
        return website_title_set_by_controller
      else
        return "#{website_title_set_by_controller} - #{application_name}"
      end
    else
      return application_name
    end
  end
  
  def application_name 
    Rails.application.class.parent_name
  end
  
  def app_name
    application_name
  end
  
end
