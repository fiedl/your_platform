class Mobile::EventsController < ApplicationController

  def show
    @event = Event.find params[:id]
    authorize! :read, @event

    @documents = @event.attachments.find_by_type('pdf')
    set_current_title @event.title
  end

end