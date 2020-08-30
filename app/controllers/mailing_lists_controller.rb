class MailingListsController < ApplicationController

  # https://railscasts.com/episodes/259-decent-exposure
  #
  expose :mailing_lists, -> { MailingList.all }

  def index
    authorize! :index, MailingList

    set_current_title t :mailing_lists
    set_current_tab :communication
  end

  def new
    authorize! :create, MailingList

    set_current_title "E-Mail-Verteiler einrichten"
    set_current_tab :communication
  end

end