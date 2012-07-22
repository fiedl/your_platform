# -*- coding: utf-8 -*-
module BoxHelper

  def content_box( options = {} )
    heading = options[ :heading ]
    content = options[ :content ]
    content = yield unless content

    render partial: 'shared/box', locals: { heading: heading, content: content }
  end

  def convert_to_content_box( html_code = nil )
    html_code = yield unless html_code
    html_convert_h1_to_boxes( html_code )
  end

  def html_convert_h1_to_boxes( html_code )
    return html_code if not html_code.start_with? "<h1>"
    
    # Further Nokogiri Reference
    # * http://stackoverflow.com/questions/3449767/find-and-replace-entire-html-nodes-with-nokogiri 
    # * http://www.engineyard.com/blog/2010/getting-started-with-nokogiri/
    # * http://nokogiri.org/Nokogiri/XML/Node.html#method-i-next_element
    doc = Nokogiri::HTML( html_code )

    doc.xpath( '//h1' ).collect do |h1_node|
      heading = h1_node.inner_html.html_safe
      content = h1_node.next_element.to_html.html_safe
      content_box( heading: heading, content: content )
    end.join.html_safe
  end

end
