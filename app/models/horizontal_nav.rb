# This extends the your_platform HorizontalNav model.
require_dependency YourPlatform::Engine.root.join( 'app/models/horizontal_nav' ).to_s

class HorizontalNav
  
  # Override the navables method in order to add Bvs to the horizontal nav.
  #
  alias_method :orig_navables, :navables
  def navables
    return orig_navables + [ @user.bv ] if @user.bv if @user
    return orig_navables
  end

end
