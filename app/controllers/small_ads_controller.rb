class SmallAdsController < ApplicationController

  expose :gesuche, -> { ProfileField.ich_suche.order(updated_at: :desc).where.not(profileable_id: current_user.id) }
  expose :angebote, -> { ProfileField.ich_biete.order(updated_at: :desc).where.not(profileable_id: current_user.id) }

  def index
    authorize! :index, :small_ads

    set_current_title "Gesuche und Angebote"
    set_current_tab :network
  end

end