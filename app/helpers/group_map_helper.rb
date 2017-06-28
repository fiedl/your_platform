module GroupMapHelper

  def group_map_items
    parent_group = @page ? Group.find(@page.group_map_parent_group_id) : Group.corporations_parent
    @group_map_items ||= MapItem.from_groups(parent_group).select { |map_item| map_item.longitude.present? }
  end

end