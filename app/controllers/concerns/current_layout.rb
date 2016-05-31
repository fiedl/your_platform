concern :CurrentLayout do

  included do
    helper_method :current_logo_url
  end

  def current_logo_url
    #current_navable.nav_node.breadcrumb_root
    Attachment.logos.first.try(:file).try(:url)
  end

end