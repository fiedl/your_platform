class AccommodationsController < ApplicationController

  expose :corporation
  expose :institution, -> { corporation.accommodations_institution }
  expose :rooms, -> { Naturally.sort corporation.rooms.order(:name), by: :name }

  expose :postal_address, -> { institution.postal_address || corporation.postal_address }
  expose :phone, -> { institution.phone || corporation.phone }
  expose :bank_account, -> { institution.bank_account || corporation.bank_account }

  def index
    authorize! :index_accommodations, corporation
    backend_migration

    set_current_title "Wohnheim #{corporation.title}"
    set_current_tab :contacts
  end

  private

  def backend_migration
    if rooms.none?
      corporation.sub_group("Hausbewohner").child_groups
        .regular.where(type: nil)
        .update_all type: "Groups::Room"
    end
    if institution.blank?
      raise "Für die Verbindung #{corporation.title} ist noch kein Wohnheimsverein (Groups::Wohnheimsverein) eingetragen."
    end
  end

end