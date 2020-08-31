class ContactsController < ApplicationController

  expose :user, -> { current_user }
  expose :corporations, -> { user.corporations }
  expose :bvs, -> { [user.bv] - [nil] }
  expose :organisations, -> { corporations + bvs }
  expose :contacts, -> {
    User.includes(:groups, :avatar_attachments, :phone_and_fax_fields, :email_and_mailing_list_fields, {address_profile_fields: [:flags, :children]}).alive.wingolfiten.where(groups: {id: organisations}).order(:last_name)
  }

  def index
    authorize! :index, :contacts

    set_current_title "Kontaktdaten meiner Bundesbrüder"
    set_current_tab :contacts
  end

end