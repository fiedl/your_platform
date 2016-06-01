module LogoHelper

  def logo_url
    unless @logo_url
      @logo_url = current_logo_url if defined?(current_logo_url)
      @logo_url ||= Attachment.logos.first.try(:file).try(:url)

      # TODO # #current_navable.nav_node.breadcrumb_root

      @logo_url ||= image_url('logo.png')
      @logo_url = root_url + @logo_url unless @logo_url.start_with? "http"
    end
    @logo_url
  end

end