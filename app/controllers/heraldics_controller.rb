class HeraldicsController < ApplicationController

  expose :corporations, -> { Corporation.all.includes(:description_fields).order(:name) }
  expose :heraldic_field_labels, -> { ["Wahlspruch", "Band", "Mütze", "Tönnchen"] }

  def index
    authorize! :index, :heraldics

    set_current_title "Heraldik"
    set_current_tab :documents
  end

end