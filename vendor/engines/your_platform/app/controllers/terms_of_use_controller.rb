class TermsOfUseController < ApplicationController
  
  skip_authorize_resource only: 'index'
  
  def index
    authorize! :read, :terms_of_use
    @current_terms_stamp = current_terms_stamp
  end
  
  def accept
    authorize! :accept, :terms_of_use
    
    if params[:accept] == 'agreed'
      flash[:notice] = I18n.t(:terms_of_use_accepted)
      current_user.accept_terms current_terms_stamp
      redirect_to (params[:redirect_after] || root_path), method: 'get'
    else
      flash[:error] = I18n.t(:you_have_to_accept_these_terms)
      redirect_to action: 'index', redirect_after: params[:redirect_after]
    end
  end
  
  def self.accepted?(current_user)
    current_user.accepted_terms?(current_terms_stamp)
  end
  
  def self.current_terms_stamp
    self.new.current_terms_stamp
  end
  
  def current_terms_stamp
    render_to_string('_terms', layout: false).lines.first
  end
  
end