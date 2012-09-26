class AddSlimMenuAttributeToRootPage < ActiveRecord::Migration
  def up
    
    # Add slim_menu attribute to the root page entry (wingolf.org).
    if Page.find_root
      nav_node = Page.find_root.nav_node
      nav_node.slim_menu = true
      nav_node.save
    end

  end
  def down

    if Page.find_root
      nav_node = Page.find_root.nav_node
      nav_node.slim_menu = false
      nav_node.save
    end

  end
end
