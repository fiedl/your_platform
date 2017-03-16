module ProfileFields

  # Homepage Field
  #
  class Homepage < ProfileField
    def self.model_name; ProfileField.model_name; end

    def display_html
      url = self.value || ''
      url = "http://#{url}" unless url.starts_with? 'http://' or url == "—"
      if url.starts_with?( "http://" )
        ActionController::Base.helpers.link_to url, url
      else
        url
      end
    end
  end

end
