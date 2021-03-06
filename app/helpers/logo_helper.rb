module LogoHelper

  def logo_url(key = nil)
    url = current_logo_url(key) if defined? current_logo_url
    url ||= global_logo_url
    url = root_url.chomp("/") + url unless url.start_with? "http"
    url
  end

  def global_logo_url
    unless @logo_url
      @logo_url = Attachment.logos.first.try(:file).try(:url)

      # TODO # #current_navable.nav_node.breadcrumb_root

      @logo_url ||= image_url('logo.png')
      @logo_url = root_url + @logo_url unless @logo_url.start_with? "http"
    end
    @logo_url
  end

  def logo
    if current_navable
      link_to current_navable.home_page do
        image_tag logo_url
      end
    else
      image_tag logo_url
    end
  end

  def logo_image_tag(key = nil)
    image_tag logo_url(key)
  end

  # To which path leads the logo?
  # - To the public website if present.
  # - To the intranet if already on the public website.
  # - To the intranet if no public website present.
  #
  def logo_link_path
    if Page.public_website_present?
      if current_navable.kind_of?(Page) && current_navable.has_flag?(:root)
        root_path
      else
        public_root_path
      end
    else
      root_path
    end
  end
end