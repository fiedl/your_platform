concern :FastLane do

  # This is for rendering a page as fast as possible,
  # therefore ignoring the current user.
  # This only works for public pages, i.e. pages that
  # do not require a signed-in user.
  #
  # This method needs to be called after `set_current_navable`
  # as this would reset the `current_ability`.
  #
  def use_the_fast_lane
    params[:fast_lane] = true
    @current_ability = Ability.new(nil)
    params[:preview_as] = 'user'
  end

end