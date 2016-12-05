# The application can be set in demo mode by passing
#
#     ?demo_mode=true
#
# to a url, and exit demo mode with `?demo_mode=false`.
#
# In demo mode, names, contact data, bank accounts
# and other sensitive data is obscured in order to allow
# screen demos on a live system.
#
concern :DemoMode do

  included do
    helper_method :demo_mode?
  end

  def demo_mode?
    if @demo_mode.nil?
      cookies[:demo_mode] = params[:demo_mode] if params[:demo_mode]
      @demo_mode = cookies[:demo_mode].to_b
    end
    @demo_mode
  end

end