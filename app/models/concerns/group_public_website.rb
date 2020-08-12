concern :GroupPublicWebsite do

  def public_pages
    descendant_pages.public_pages
  end

  def public_home_page
    child_pages.where(type: "Pages::PublicPage").first
  end

  def generate_public_website
    homepage = child_pages.where(type: "Pages::PublicPage").first
    if not homepage
      homepage = Pages::PublicPage.create title: "Willkommen", content: "<h2>Willkommen zu eurer neuen Homepage</h2>Fang doch am Besten mit einer kurzen Begrüßung an."
      child_pages << homepage
    end
    about = generate_public_website_page title: "Über uns", content: "<h2>Über uns</h2>Beschreibe hier doch kurz, wer ihr seid."
    studieren = generate_public_website_page title: "Studieren", content: "<h2>Studieren im Wingolf</h2>Beschreibe kurz, warum es es besser ist, mit eurer Verbindung zu studieren."
    wohnen = generate_public_website_page title: "Wohnen", content: "<h2>Wohnen im Wingolf</h2>Beschreibe beispielsweise kurz, was ihr für Zimmer habt und welche Mieter ihr sucht."
    veranstaltungen = generate_public_website_page title: "Veranstaltungen"
    fotos = generate_public_website_page title: "Fotos", type: "Pages::PublicGalleryPage", content: "<h2>Fotos</h2>Auf diese Seite kannst Du ein ppar Fotos hochladen."
    kontakt = generate_public_website_page title: "Kontakt", content: "<h2>Kontakt</h2><p>#{group.title}<br />#{group.postal_address.gsub("\n", "<br />")}</p><h2>Impressum</h2>..."

    return homepage
  end

  def generate_public_website_page(page_params)
    page = public_home_page.public_child_pages.where(title: page_params[:title]).first
    if not page
      page = Pages::PublicPage.create page_params
      public_home_page.child_pages << page
    end
    return page
  end

end