class PrivacyController < ApplicationController
  
  def index
    flag = I18n.t(:privacy).downcase
    @page = Page.find_by_flag(flag) || raise("Page with flag :#{flag} not found.")
    
    authorize! :read, @page
    redirect_to @page
  end
  
end