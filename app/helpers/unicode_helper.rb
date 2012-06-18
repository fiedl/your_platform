module UnicodeHelper
  
  def replace_unicode_special_chars_by_html_escape_strings( html_code )
    c = html_code
    c.gsub!( "\u2009", "&thinsp;" ) # thin space
    return c.html_safe
  end

end
