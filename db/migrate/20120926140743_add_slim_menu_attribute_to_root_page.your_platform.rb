class AddSlimMenuAttributeToRootPage < ActiveRecord::Migration[4.2]
  def up

    # This is not needed for fresh installs anymore.
    #
    # # # Add slim_menu attribute to the root page entry (wingolf.org).
    # # if Page.find_root
    # #   nav_node = Page.find_root.nav_node
    # #   nav_node.slim_menu = true
    # #   nav_node.save
    # # end

  end
  def down

    # This is not needed for fresh installs anymore.
    #
    # # if Page.find_root
    # #   nav_node = Page.find_root.nav_node
    # #   nav_node.slim_menu = false
    # #   nav_node.save
    # # end

  end
end
