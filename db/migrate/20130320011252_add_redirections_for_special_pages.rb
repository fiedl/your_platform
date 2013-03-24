class AddRedirectionsForSpecialPages < ActiveRecord::Migration
  def up
    if Page.find_root && Page.find_intranet_root
      Page.find_root.update_attributes( :redirect_to => "http://wingolf.org" )
      Page.find_intranet_root.update_attributes( :redirect_to => "root#index" )
    end
  end
end
