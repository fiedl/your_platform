require 'nokogiri'

module BoxHelper

  def content_box( options = {} )
    heading = options[ :heading ]
    content = options[ :content ]
    content = yield unless content
    box_class = options[:box_class]
    box_id = options[:box_id]

    render partial: 'layouts/box', locals: {heading: heading, content: content, box_class: box_class, box_id: box_id}
  end

  def convert_to_content_box( html_code = nil )
    Rack::MiniProfiler.step("convert_to_content_box") do
      html_code = yield unless html_code
      html_convert_h1_to_boxes( html_code )
    end
  end

  def html_convert_h1_to_boxes( html_code, options = {} )

    # Further Nokogiri Reference
    # * http://stackoverflow.com/questions/3449767/
    # * http://www.engineyard.com/blog/2010/getting-started-with-nokogiri/
    # * http://nokogiri.org/Nokogiri/XML/Node.html#method-i-next_element
    # * http://stackoverflow.com/questions/4723344/how-to-prevent-nokogiri-from-adding-doctype-tags
    # * http://stackoverflow.com/questions/3817843/using-xpath-with-html-or-xml-fragment
    #
    doc = Nokogiri::HTML::DocumentFragment.parse( html_code )

    box_counter = 0
    doc.xpath( 'descendant::h1' ).each do |h1_node|
      box_counter += 1
      heading = h1_node.inner_html.html_safe
      heading_class = h1_node.attr( :class )
      heading_class ||= ""
      heading_class += " first" if box_counter == 1
      heading_id = h1_node.attr(:id)

      content_element = h1_node.next_element
      if content_element
        content = content_element.to_html.html_safe
        content_element.remove()
      end
      content ||= "" # because content_box expects a String

      h1_node.replace content_box(heading: heading, content: content, box_class: heading_class, box_id: heading_id)
    end

    return doc.to_s.html_safe
  end

  def show_box_edit_button?(box_class, navable)
    return can? :create_attachment_for, navable if box_class == 'attachments'
    return can? :update, navable
  end

end
