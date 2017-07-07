module GroupMapHelper

  def group_map_items
    parent_group = @page ? Group.find(@page.group_map_parent_group_id) : Group.corporations_parent
    @group_map_items ||= MapItem.from_groups(parent_group).select { |map_item| map_item.longitude.present? }
  end

  def group_map_title
    if group_map_items.count == 1
      t :group_map_title_singular
    else
      t :group_map_title
    end
  end

end