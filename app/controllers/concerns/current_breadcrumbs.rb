concern :CurrentBreadcrumbs do

  included do
    helper_method :current_breadcrumbs
  end

  def current_breadcrumbs
    @current_breadcrumbs
  end

  def set_current_breadcrumbs(hash)
    @current_breadcrumbs = hash
  end

end