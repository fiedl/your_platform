class Mobile::ContactsController < ApplicationController

  def index
    authorize! :read, :mobile_contacts

    set_current_title "Adressbuch"
  end

end