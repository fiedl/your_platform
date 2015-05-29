concern :RedirectWwwSubdomain do
  
  included do
    before_action :redirect_www_subdomain
  end
  
  # Redirect the www subdomain to non-www, e.g.
  # http://www.example.com to http://example.com.
  #
  def redirect_www_subdomain
    if (request.host.split('.')[0] == 'www') and (not Rails.env.test?)
      # A flash cross-domain flash message would only work if the cookies are shared between the subdomains.
      # But we won't make this decision for the main app, since this can be a security risk on shared domains.
      # More info on sharing the cookie: http://stackoverflow.com/questions/12359522/
      #
      flash[:notice] = I18n.t(:you_may_leave_out_www)
      redirect_to "http://" + request.host.gsub('www.','')
    end
  end
  
end