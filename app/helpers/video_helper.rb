module VideoHelper

  # Inserts a video_tag using afterglow.
  # Make sure the afterglow script is included in the layout's header.
  #
  # https://github.com/moay/afterglow
  #
  def afterglow_video(attachment)

    # TODO: Fullscreen via double click.
    # https://github.com/moay/afterglow/issues/27

    video_tag attachment.file.url, video_tag_default_options.merge({
      id: "video-attachment-#{attachment.id}",
      width: attachment.width,
      height: attachment.height
    })
  end

  def replace_video_links(markup)
    markup.gsub(/(.*.(mp4|m4v))/) { |url|
      #video_tag(url, video_tag_default_options)
      content_tag :video, {controls: true, class: 'video'} do
        content_tag :source, "", {src: url, type: "video/mp4"}
      end
    }
  end

  def video_tag_default_options
    {
      class: 'afterglow video',
      type: 'video/mp4',
      controls: true,
      data: {
        autoresize: 'fit'
      }
    }
  end

end

# In order to use the markup helper method with best_in_place's :display_with argument,
# the ActionView::Base has to include the markup method.
#
module ActionView
  class Base
    include VideoHelper
  end
end
