class MagazinesController < ApplicationController

  expose :magazines, -> { Magazine.all }

  def index
    authorize! :index, Magazine

    set_current_title "Zeitschriften"
    set_current_tab :communication
  end

end