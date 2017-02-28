concern :CurrentBreadcrumbs do

  included do
    helper_method :manual_current_breadcrumbs
  end

  def manual_current_breadcrumbs
    @current_breadcrumbs
  end

  def set_current_breadcrumbs(hash)
    @current_breadcrumbs = hash
  end

end