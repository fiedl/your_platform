module TitleHelper
  
  def website_title_set_by_controller
    @title
    # alternative?:   content_for?(:title) ? yield(:title) : "YourPlatform"
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
