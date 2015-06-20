module AccessIndicatorHelper
  
  # This indicator shows
  # - a closed "lock" if the user can see this content due to admins override
  # - an open lock ("unlock") if the user can see this restricted content
  # - a group of people ("users") if all registed users can see this content
  # - a "globe" if all internet users can see this content
  #
  def access_indicator
    if current_access
      css = 'access-indicator has_tooltip'
      css += ' private' if current_access.to_s.in? ['group']
      css += ' ' + current_access.to_s
      if params[:admins_only_override].present?
        css += ' override'
        append_to_current_access_text :you_have_used_your_admin_rights_to_override
      end
      content_tag 'span', title: current_access_text, class: css, data: {placement: 'right'} do
        awesome_icon(current_access_icon)
      end
    end
  end
  
end