class ApplicationController < ActionController::Base
  protect_from_forgery

  layout "bootstrap"

  include CurrentTimeZone
  include CurrentUser
  include CurrentNavable
  include CurrentTitle
  include CurrentActivity
  include CurrentTab
  include CurrentIssues
  include CurrentLocale
  include CurrentAbility
  include CurrentRole
  include CurrentAccess

  include RedirectWwwSubdomain
  include CheckAuthorization
  include AcceptTermsOfUse
  include ReadOnlyMode
  include ConfirmAdminsOnlyAccess
  include GenericMetricLogging

  private
  
  # We use this custom method to render a partial to a json string.
  #
  def render_partial(partial, locals = {})
    render_to_string(partial: partial, locals: locals, layout: false, formats: [:html])
  end
  
end
