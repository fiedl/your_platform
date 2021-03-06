class GesucheUndAngeboteController < ApplicationController

  expose :gesuche, -> { ProfileField.ich_suche.order(updated_at: :desc).where.not(profileable_id: current_user.id).select { |profile_field| profile_field.profileable.kind_of?(User) && profile_field.profileable.alive? && profile_field.profileable.wingolfit? } }
  expose :angebote, -> { ProfileField.ich_biete.order(updated_at: :desc).where.not(profileable_id: current_user.id).select { |profile_field| profile_field.profileable.kind_of?(User) && profile_field.profileable.alive? && profile_field.profileable.wingolfit? } }

  def index
    authorize! :index, :gesuche_und_angebote

    set_current_title t(:gesuche_und_angebote)
    set_current_tab :network
  end

end