module BestInPlaceHelper
  
  def best_in_place_activator(activator_id)
    link_to(icon(:edit), '#', id: activator_id)
  end
  
end