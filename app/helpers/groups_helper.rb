module GroupsHelper
  
  def groups_of_user_ul( user )
    Group
    groups = Groups.of_user user
    content_tag :ul do
      (groups.collect do |group|
        group_li group
      end).join.html_safe
    end
  end

  def group_list_item( group )
    content_tag :li do
      link_to group.name, controller: 'groups', action: 'show', id: group.id
    end
  end

  def group_li( group )
    group_list_item group
  end

end
