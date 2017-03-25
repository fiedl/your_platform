class ContactMessagesController < ApplicationController

  # https://railscasts.com/episodes/259-decent-exposure
  #
  expose :contact_message

  def new
    authorize! :create, ContactMessage

    set_current_title t(:new_contact_message_title)
    set_current_breadcrumbs [
      {title: current_title}
    ]
  end

  def create
    authorize! :create, ContactMessage

    ContactMessage.new(contact_message_params).deliver

    redirect_to public_root_path, notice: t(:contact_message_has_been_sent)
  end

  private

  def contact_message_params
    params.require(:contact_message).permit(:subject, :name, :email, :message, :nickname)
  end

end