# When playing a blog-post teaser video, count that as a show
# event for the view counter. Therefore, trigger a GET request
# on the blog post.
#
$(document).ready ->
  $('.blog_post.teaser_box video').off('play').on 'play', ->
    video_tag = $(this)
    post_url = video_tag.closest('.teaser_box')
        .find('.box_title a').attr('href')
    unless video_tag.data('view_counter_done')
      $.get post_url
      video_tag.data 'view_counter_done', true
