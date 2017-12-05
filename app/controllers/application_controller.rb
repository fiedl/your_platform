class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include CurrentLayout
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
  include CurrentBreadcrumbs
  include CurrentHelp

  include CheckAuthorization
  include AcceptTermsOfUse
  include ReadOnlyModeInControllersAndViews
  include DemoMode
  include FastLane
  include ConfirmAdminsOnlyAccess
  include GenericMetricLogging


  # We use this custom method to render a partial to a json string.
  #
  def render_partial(partial, locals = {})
    render_to_string(partial: partial, locals: locals, layout: false, formats: [:html])
  end
  helper_method :render_partial

  def url_for(args = {})
    if args.respond_to?(:permalinks) && args.permalinks.any?
      super(args.permalink_path)
    else
      super
    end
  end
  helper_method :url_for

end
