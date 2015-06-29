module I18nHelper
  
  def language_switcher_html
    I18n.available_locales.collect do |language|
      # tag(:img, :class => "flag flag-#{language}", :alt => language)
      link_to language, { locale: language }
    end.join(" | ").html_safe
  end

  # avoid exceptions in views
  def translate(key, options={})
    super(key, options.merge(raise: true))
  rescue I18n::MissingTranslationData
    key
  end
  alias :t :translate
  
end
