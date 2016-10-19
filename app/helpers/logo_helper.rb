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

  def logo_image_tag(logo_key = nil)
    logo_path = Attachment.logos.where(title: logo_key).last.try(:file_path) if logo_key
    logo_path ||= current_logo_url if current_logo
    logo_path ||= default_logo
    image_tag logo_path
  end

end