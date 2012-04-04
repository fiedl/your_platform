module BoxHelper

  def content_box( args, &block ) # :heading
    content = with_output_buffer( &block )
    html_code = render :partial => "shared/box", :locals => { :heading => args[:heading], :content => content }
    return html_code
  end

  def convert_to_content_box ( &block )
    html_code_to_convert = yield
    if html_code_to_convert.start_with? "<h1>"
      html_code_to_return = ""
      doc = Nokogiri::HTML( html_code_to_convert ) 
      # Node-HTML-Struktur, siehe http://stackoverflow.com/questions/3449767/find-and-replace-entire-html-nodes-with-nokogiri
      # http://www.engineyard.com/blog/2010/getting-started-with-nokogiri/
      doc.xpath('//h1').each do |h1_node|
        heading = h1_node.text 
        content = h1_node.next_element.inner_html.html_safe #http://nokogiri.org/Nokogiri/XML/Node.html#method-i-next_element
        html_code_to_return += content_box( :heading => heading ) { concat content }
      end
      return html_code_to_return.html_safe
    else
      return html_code_to_convert
    end
  end

end
