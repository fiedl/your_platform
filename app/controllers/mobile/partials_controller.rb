class Mobile::PartialsController < ApplicationController
  layout false

  # GET /mobile/partials/:partial_key
  # Example: GET /mobile/partials/events
  #
  def show
    authorize! :read, :mobile_dashboard
    @partial_key = params[:partial_key]
    load_resources
  end

  private

  def load_resources
    case params[:partial_key]
    when 'events'
      @events = current_user.upcoming_events.limit(5)
    when 'recent_contacts'
      @recent_contacts = current_user.recent_contacts.last(5)
    when 'people_search_results'
      @found_users = User.search(params[:query])
        .select { |user| can?(:read, user) && user.alive? && user.wingolfit? }
    else
      raise("partial #{params[:partial_key]} not handled in load_resources.")
    end
  end

end