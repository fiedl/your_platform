module VideoHelper

  # Inserts a video_tag using afterglow.
  # Make sure the afterglow script is included in the layout's header.
  #
  # https://github.com/moay/afterglow
  #
  def afterglow_video(attachment)

    # TODO: Fullscreen via double click.
    # https://github.com/moay/afterglow/issues/27

    video_tag attachment.file.url, {
      class: 'afterglow video',
      id: "video-attachment-#{attachment.id}",
      width: attachment.width,
      height: attachment.height,
      type: 'video/mp4',
      controls: "true",
      data: {
        autoresize: 'fit'
      }
    }
  end

end