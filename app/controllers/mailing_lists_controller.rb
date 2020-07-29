class MailingListsController < ApplicationController

  # https://railscasts.com/episodes/259-decent-exposure
  #
  expose :mailing_lists, -> { MailingList.all }

  def index
    authorize! :index, MailingList

    set_current_title t :mailing_lists
    set_current_tab :communication
    set_current_breadcrumbs [
      {title: current_title}
    ]

    set_current_access :signed_in
    set_current_access_text t :all_signed_in_users_can_read_this_content
  end

end