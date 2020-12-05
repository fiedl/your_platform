concern :UserCouleur do

  def couleurs
    sorted_current_corporations.collect do |corporation|
      case current_status_in corporation
      when "Hospitant"
        corporation.couleur_hospitanten
      when "Konkneipant"
        corporation.couleur_konkneipanten
      when "Kraßfux", "Brandfux", "Fux"
        corporation.couleur_fuxen
      else
        corporation.couleur
      end
    end
  end

end