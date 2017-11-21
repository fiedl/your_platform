module RssHelper

  def generate_rss_feed(xml, args = {})
    args[:root_element] || raise(ActionController::ParameterMissing, 'no :root_element given')
    args[:items] || raise(ActionController::ParameterMissing, 'no :items given')

    description = args[:root_element].description if args[:root_element].respond_to? :description
    description ||= args[:root_element].content if args[:root_element].respond_to? :content

    # http://railscasts.com/episodes/87-generating-rss-feeds-revised?autoplay=true
    #
    xml.instruct! :xml, version: "1.0"
    xml.rss version: "2.0", 'xmlns:content' => "http://purl.org/rss/1.0/modules/content/" do
      xml.channel do
        xml.title args[:root_element].title
        xml.description description
        xml.link url_for(args[:root_element])
        xml.generator "https://github.com/fiedl/your_platform"

        args[:items].each do |item|
          xml.item do
            xml.title item.title
            xml.description item.content
            xml.pubDate item.published_at.to_s(:rfc822)
            xml.link item.url
            xml.guid item.url
            xml.tag! 'content:encoded' do
              xml.cdata! ((image_tag(item.teaser_image_url).html_safe if item.respond_to? :teaser_image_url and item.teaser_image_url).to_s + item.teaser_text.to_s)
            end
          end
        end
      end
    end
  end

  def rss_button(url = nil)
    url ||= rss_default_url
    link_to url, class: 'btn btn-default btn-xs' do
      rss_icon
    end
  end

  def rss_default_url
    feed_path(id: 'default', format: 'rss', token: current_user.try(:token))
  end

end