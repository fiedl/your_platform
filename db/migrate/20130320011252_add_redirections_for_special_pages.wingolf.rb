class AddRedirectionsForSpecialPages < ActiveRecord::Migration[4.2]
  def up
    # This is not needed for fresh installs anymore.
    #
    # # if Page.find_root && Page.find_intranet_root
    # #   Page.find_root.update_attributes( :redirect_to => "http://wingolf.org" )
    # #   Page.find_intranet_root.update_attributes( :redirect_to => "root#index" )
    # # end
  end
end
