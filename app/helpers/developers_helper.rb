module DevelopersHelper
  
  def group_handle(group)
    if current_user.developer?
      content_tag :span, class: 'icon-small copy-to-clipboard', title: "Group.find(#{group.id})" do
        icon(:wrench)
      end.html_safe
    end
  end
  
end