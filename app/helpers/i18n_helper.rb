module I18nHelper
  
  def language_switcher_html
    I18n.available_locales.collect do |language|
      # tag(:img, :class => "flag flag-#{language}", :alt => language)
      link_to language, { locale: language }
    end.join(" | ").html_safe
  end
  
end
