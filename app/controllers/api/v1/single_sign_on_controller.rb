module Api::V1
  class SingleSignOnController < ApplicationController
    
    # GET /api/v1/sso?sso=PAYLOAD&sig=SIG
    # 
    #    The PAYLOAD is a base64 encoded string containing a nonce,
    #    e.g. "nonce=ABCD".
    #
    # See also:
    # - https://meta.discourse.org/t/official-single-sign-on-for-discourse/13045
    # - https://github.com/discourse/discourse/blob/master/app/models/discourse_single_sign_on.rb
    # 
    def sign_in
      authorize! :use, :single_sign_on
      
      secret = Rails.application.secrets.sso_secret || raise('no sso_secret configured')
      
      request.query_string.include?("sso=") || raise('no "sso" parameter given')
      request.query_string.include?("sig=") || raise('no "sig" parameter given')
      
      sso = SingleSignOn.parse(request.query_string, secret)
      
      sso.email = current_user.email
      sso.name = current_user.title
      sso.username = current_user.alias
      sso.username = current_user.email unless sso.username.present?
      sso.avatar_url = view_context.user_avatar_url(current_user)
      
      #sso.avatar_force_update = true
      sso.admin = current_user.global_admin?
      sso.external_id = current_user.id
      sso.sso_secret = secret

      redirect_to sso.to_url(sso.return_sso_url)
    end
    
  end
end