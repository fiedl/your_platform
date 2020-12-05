module CouleurHelper

  # This determines which couleur ribbons will be shown in the top right of the layout.
  #
  def current_couleurs
    currently_displayed_user_couleurs || current_public_website_couleurs || current_corporation_couleurs || current_user_couleurs
  end

  def currently_displayed_user_couleurs
    current_navable.couleurs if current_navable.kind_of?(User) && current_navable.couleurs.any?
  end

  def current_user_couleurs
    current_user.couleurs if current_user && current_user.couleurs.any?
  end

  def current_public_website_couleurs
    if current_navable.kind_of?(Pages::PublicPage) && current_navable.group.respond_to?(:couleur) && current_navable.group.couleur
      [current_navable.group.couleur]
    end
  end

  def current_corporation_couleurs
    if current_navable.respond_to?(:corporation) && current_navable.corporation && current_navable.corporation.couleur
      [current_navable.corporation.couleur]
    end
  end

end