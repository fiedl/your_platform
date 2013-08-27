class ApplicationController < ActionController::Base

  layout "bootstrap"

  # TODO: Change before_filter to before_action  (http://stackoverflow.com/questions/16519828)
  #
  before_filter :set_locale
  helper_method :current_user
  
  def current_user
    current_user_account.user if current_user_account
  end
  
  # The locale of the application s set as follows:
  #   1. Use the url parameter 'locale' if given.
  #   2. Use the language of the web browser if supported by the app.
  #   3. Use the default locale if no other could be determined.
  #
  def set_locale
    cookies[:locale] = params[:locale] if params[:locale].present?
    cookies[:locale] = nil if params[:locale] and params[:locale] == ""
    cookies[:locale] = nil if cookies[:locale] == ""
    I18n.locale = cookies[:locale] || browser_language_if_supported_by_app || I18n.default_locale
  end
  
  private
  def extract_locale_from_accept_language_header
    # see: http://guides.rubyonrails.org/i18n.html
    if request.env['HTTP_ACCEPT_LANGUAGE'] and not Rails.env.test?
      request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first.to_sym
    end
  end
  def browser_language_if_supported_by_app
    ([extract_locale_from_accept_language_header] & I18n.available_locales).first
  end

end
