class FeaturesController < ApplicationController

  def index
    authorize! :index, :features

    set_current_title "Plattform-Features"
    set_current_navable Page.intranet_root
  end

  private

  def discourse_features_url
    # Override this in the main app or
    # TODO: make it configurable.
  end
  helper_method :discourse_features_url

  def github_issues_url
    "https://github.com/fiedl/your_platform/issues"
  end
  helper_method :github_issues_url

end