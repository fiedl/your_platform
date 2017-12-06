module GroupSelectHelper

  # Insert an editable field that lets the user
  # select an existing group.
  #
  # Provide an object and attribute to store the group
  # id like this:
  #
  #     group_select_in_place user, :user, :favorite_group_id
  #     group_select_in_place page, :page, :show_events_for_group_id
  #
  def group_select_in_place(object, object_key, group_id_attribute_key)
    group_id = object.send group_id_attribute_key
    group = Group.find group_id if group_id

    content_tag :div, class: 'group_select_in_place editable', data: {url: url_for(object), object_key: object_key, group_id_attribute_key: group_id_attribute_key, group_id: group_id, group_name: group.try(:name)} do
      link_to group.title, group if group
    end
  end

end