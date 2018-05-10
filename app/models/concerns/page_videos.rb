concern :PageVideos do

  def video?
    teaser_youtube_url || teaser_video_url || video_attachments.any?
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