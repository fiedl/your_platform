class Integrations::TrelloController < IntegrationsController

  def show
    authorize! :manage, :trello_integration
    set_current_title "Trello Integration"

    super
  end


end