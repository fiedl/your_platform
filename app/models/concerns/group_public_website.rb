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
      if self.subdomain.present?
        domain = "#{self.subdomain}.#{AppVersion.domain}"
        url = "https://#{domain}"
        url_paragraph = "Aktuell könnt ihr die Seite über
          <a href=\"#{url}\" target=\"_blank\">#{url}</a>
          erreichen.
        "
      end
      homepage = Pages::PublicPage.create(
        title: "Willkommen",
        domain: domain
      )
      homepage.update content: "
        <h2>Willkommen zu eurer neuen Website</h2>
        <p>Fang doch am Besten mit einer kurzen Begrüßung an.</p>
        <p>Wenn ihr fertig seid, meldet euch beim AK Internet.
          Dann helfen wir euch beim Einrichten der Domain.
          #{url_paragraph}
        </p>".gsub("\n", " ")
      child_pages << homepage
    end
    about = generate_public_website_page title: "Über uns", content: "<h2>Über uns</h2><p>Beschreibe hier doch kurz, wer ihr seid.</p>"
    studieren = generate_public_website_page title: "Studieren", content: "<h2>Studieren im Wingolf</h2><p>Beschreibe kurz, warum es es besser ist, mit eurer Verbindung zu studieren.</p>"
    wohnen = generate_public_website_page title: "Wohnen", content: "<h2>Wohnen im Wingolf</h2><p>Beschreibe beispielsweise kurz, was ihr für Zimmer habt und welche Mieter ihr sucht.</p>"
    veranstaltungen = generate_public_website_page title: "Veranstaltungen", type: "Pages::PublicEventsPage"
    fotos = generate_public_website_page title: "Fotos", type: "Pages::PublicGalleryPage", content: "<h2>Fotos</h2><p>Auf diese Seite kannst Du ein paar Fotos hochladen.</p>"
    kontakt = generate_public_website_page title: "Kontakt", content: "<h2>Kontakt</h2><p>#{self.title}<br />#{self.postal_address.gsub("\n", "<br />")}</p><h2>Impressum</h2>..."

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