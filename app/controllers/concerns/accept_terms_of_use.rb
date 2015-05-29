concern :AcceptTermsOfUse do
  
  included do
    before_action :accept_terms_of_use
  end
  
  def accept_terms_of_use
    if current_user && (not read_only_mode?) && (not controller_name.in?(['terms_of_use', 'sessions', 'passwords', 'user_accounts', 'attachments', 'errors'])) && (not TermsOfUseController.accepted?(current_user))
      if request.url.include?('redirect_after')
        redirect_after = root_path
      else
        redirect_after = request.url
      end
      redirect_to controller: 'terms_of_use', action: 'index', redirect_after: redirect_after
    end
  end
    
end