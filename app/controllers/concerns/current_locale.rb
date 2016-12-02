concern :CurrentLocale do
  
  included do
    before_action :update_locale_cookie, :update_user_locale, :set_locale
    helper_method :current_locale
  end
  
  def current_locale
    current_user.try(:locale) || I18n.locale
  end
  
  # The locale of the application s set as follows:
  #   1. Use the url parameter 'locale' if given.
  #   2. Use the `Setting.preferred_locale`, which is a global application setting, if set.
  #   3. Use the language of the web browser if supported by the app.
  #   4. Use the default locale if no other could be determined.
  #
  def set_locale
    I18n.locale = current_user.try(:locale) || cookies[:locale] || Setting.preferred_locale || browser_language_if_supported_by_app || I18n.default_locale
  end
  def update_locale_cookie
    cookies[:locale] = secure_locale_param if params[:locale].present?
    cookies[:locale] = nil if params[:locale] and params[:locale] == ""
    cookies[:locale] = nil if cookies[:locale] == ""
  end
  def update_user_locale
    if current_user && current_user.locale(true) != cookies[:locale]
      current_user.update_attribute :locale, cookies[:locale]
    end
  end
  
  private
  
  # This method prevents a DoS attack.
  #
  def secure_locale_param
    if params[:locale].present? and params[:locale].in? I18n.available_locales.collect { |l| l.to_s }
      params[:locale] 
    end
  end
  
  def secure_locale_from_accept_language_header
    # This comparison is to prevent a DoS attack.
    # See: http://brakemanscanner.org/docs/warning_types/denial_of_service/
    #
    I18n.available_locales.select do |locale|
      locale.to_s == locale_from_accept_language_header
    end.first
  end
  def locale_from_accept_language_header
    # see: http://guides.rubyonrails.org/i18n.html
    if request.env['HTTP_ACCEPT_LANGUAGE'] and not Rails.env.test?
      request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
    end
  end
  def browser_language_if_supported_by_app
    secure_locale_from_accept_language_header
  end
    
end