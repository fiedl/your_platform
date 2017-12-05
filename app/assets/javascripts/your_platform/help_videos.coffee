# This loads related help videos.

get_youtube_video_id = (url) ->
  regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/
  match = url.match(regExp)
  if match and match[2].length == 11
    match[2]
  else
    'error'

youtube_player = (url)->
  # https://stackoverflow.com/a/21607897/2066546
  embed_url = "//www.youtube.com/embed/#{get_youtube_video_id(url)}"
  "<iframe src=\"#{embed_url}\" frameborder=\"0\" allowfullscreen></iframe>"

$(document).ready ->
  if $('#help_video').count() > 0
    topics = $('#help_video').data('topics')
    $.ajax {
      url: "http://my-platform.dev/api/v1/public/blog_posts",
      method: 'get',
      data: {
        tags: topics
      },
      success: (blog_posts)->
        blog_posts = blog_posts.filter (blog_post)-> blog_post.youtube
        blog_post = blog_posts[Math.floor(Math.random() * blog_posts.length)]
        if blog_post
          url = "https://plattformpodcast.com/blog_posts/#{blog_post.id}"

          $('#help_video').html("
            <h3><a href='#{url}'>#{blog_post.title}</a></h3>
            #{youtube_player(blog_post.youtube)}
            <a class='more' href='https://plattformpodcast.com'>Mehr auf plattformpodcast.com</a>
          ")
    }