# This determines which pages are directly connected, i.e. associated with the structureable.
# This means that the pages are not separated by a group or another object from the 
# structureable.
#
# Example:
# 
#     @group
#       |
#     @page --- @subpage                       <--- connected to @group
#                  |
#               @disconnected_group
#                  |               
#               @disconnected_group_page       <--- not connected to @group
# 
concern :StructureableConnectedPages do
  
  def connected_descendant_pages
    Page.find connected_descendant_page_ids
  end
  
  def connected_descendant_page_ids
    cached { self.child_pages.collect { |child_page| [child_page.id] + child_page.connected_descendant_page_ids }.flatten }
  end
  
end