module SublimeHelper
  
  def sublime_token
    ::SECRETS["sublime_token"] || ""
  end
  
  def sublime_script_tag
    javascript_include_tag "http://cdn.sublimevideo.net/js/#{sublime_token}.js" if sublime_token.present?
  end
  
end