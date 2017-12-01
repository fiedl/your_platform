class BlogPost < Page
  include Commentable

  def as_json(*args)
    super.merge({
      youtube: teaser_youtube_url
    })
  end

end
