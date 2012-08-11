# -*- coding: utf-8 -*-
module BackendHorizontalNavHelper

  # Horizontale Navigation / Kategorie-Anzeiger
  def backend_horizontal_nav

    # Wichtige Controller-Variablen:
    # @current_user    # der aktuell angemeldete Benutzer
    # @navable         # die aktell angezeigte Seite, Gruppe, ...

    content_tag :ul do
      backend_horizontal_nav_lis
    end

  end

  def backend_horizontal_nav_lis
    c = navables_for_backend_horizontal_nav.collect do |navable_to_display_in_horizontal_nav|
      backend_horizontal_nav_item navable_to_display_in_horizontal_nav
    end.join.html_safe
    unless @current_user # Temporärer Login-Link
      c += content_tag :li do
        link_to "Login", controller: 'sessions', action: 'new'
      end
    end
    c
  end

  def backend_horizontal_nav_item( navable_to_display_in_horizontal_nav )

    # Die horizontale Navigation fungiert als Kategorie-Anzeiger. Wenn man sich gerade auf einer Seite befindet,
    # die einem Menü-Element entspricht, wird dieses Menü-Element als aktiv dargestellt. Befindet man sich in
    # der Hierarchie unterhalb, wird es auch, aber etwas schwächer, hervorgehoben, sodass man erkennt, dass man
    # sich unterhalb dieser Kategorie befindet.
    # Hierbei soll man sich aber höchstens in einer Kategorie befinden können, auch wenn es durch Verschachtelung
    # möglich wäre, dass man sich gleichzeitig in mehreren befindet, nämlich in einer angezeigten Ober- und einer
    # ihrer Unterkategorien. Daher wird nur die speziellste der angezeigten Kategorien hervorgehoben, unter denen
    # man sich befindet.

    style_class = "active" if navable_is_currently_shown?( navable_to_display_in_horizontal_nav )
    style_class = "under_this_category" if navable_to_display_in_horizontal_nav == most_special_category unless style_class

    content_tag :li, :class => style_class do
      link_to( navable_title_to_show_in_horizontal_nav( navable_to_display_in_horizontal_nav ),
               navable_path( navable_to_display_in_horizontal_nav ) )
    end

  end

  # Array der Navables (Seiten, Gruppen, etc.), die in der horizontalen Navigation
  # des Mitgliederbereichs angezeigt werden sollen.
  def navables_for_backend_horizontal_nav
    navables = []
    navables += [ Page.find_intranet_root ] if Page.find_intranet_root
    if @current_user
      if @current_user.corporations 
        navables += @current_user.corporations.collect { |corporation| corporation.becomes Group }  
      end
    end
    navables += [ @current_user.bv.becomes( Group ) ] if @current_user.bv if @current_user
    return navables
  end

  def categories_the_current_navable_falls_in
    if currently_shown_navable
      navables_for_backend_horizontal_nav.select do |navable|
        ( currently_shown_navable.ancestors + [ currently_shown_navable ] ).include? navable
      end
    end
  end

  def most_special_category
    if categories_the_current_navable_falls_in
      categories_the_current_navable_falls_in.select do |navable|
        (navable.descendants & categories_the_current_navable_falls_in).empty?
      end.first
    end
  end

  def currently_shown_navable
    return @navable
  end

  def navable_is_currently_shown?( navable )
    navable == currently_shown_navable
  end

  def navable_title_to_show_in_horizontal_nav( navable )
    title = navable.title
    #if total_length_of_nav_titles > 60
    if title.length > 16
      title = navable.internal_token if navable.respond_to? :internal_token
      title = navable.token if navable.respond_to? :token unless title
      title = navable.title unless title
    end
    return title
  end

  def total_length_of_nav_titles
    length_counter = 0
    navables_for_backend_horizontal_nav.each{ |nav| length_counter += nav.title.length }
    return length_counter
  end

  def navable_path( navable )
    main_app.send( "#{navable.class.name.downcase}_path".to_sym, navable )
    # e.g. main_app.page_path( navable )  for a Page
  end

end
