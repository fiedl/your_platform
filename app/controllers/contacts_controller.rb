class ContactsController < ApplicationController

  expose :user, -> { current_user }
  expose :corporations, -> { user.corporations }
  expose :bvs, -> { [user.bv] - [nil] }
  expose :organisations, -> { corporations + bvs }
  expose :contacts, -> {
    User.includes(:groups, :avatar_attachments).alive.wingolfiten.where(groups: {id: organisations}).order(:last_name)
  }

  def index
    authorize! :index, :contacts

    set_current_title "Kontaktdaten meiner Bundesbrüder"
    set_current_tab :contacts
  end

end