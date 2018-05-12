class BlogPost < Page
  include Commentable

  include HostAndGuestGroups

  def as_json(*args)
    super.merge({
      youtube: teaser_youtube_url
    })
  end

end
