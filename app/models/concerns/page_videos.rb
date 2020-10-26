concern :PageVideos do

  def video?
    video_url.present?
  end

  def video_url
    teaser_youtube_url || teaser_video_url || video_attachments.first.try(:url)
  end

  def raw_video_url
    teaser_video_url || video_attachments.first.try(:url) || raw_youtube_video_url
  end

  def raw_youtube_video_url
    # `y-dl --get-url -f best #{teaser_youtube_url}`.strip if teaser_youtube_url
  end

  def video_attachments
    attachments_by_type("video")
  end

  def teaser_youtube_url
    content.to_s.match(/(https?\:\/\/)?(www\.)?(youtube\.com|youtu\.?be)\/.+/).try(:[], 0)
  end

  def teaser_video_url
    content.to_s.match(/(https?\:\/\/.*.(mp4|m4v))/).try(:[], 0)
  end

end