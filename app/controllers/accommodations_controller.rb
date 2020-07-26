class AccommodationsController < ApplicationController

  expose :corporation
  expose :institution, -> { corporation.accommodations_institution }
  expose :rooms, -> { corporation.rooms.order(:name) }

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