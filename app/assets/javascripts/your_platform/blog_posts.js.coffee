$(document).on 'click', '.add_blog_post', ->
  $(this).fadeOut()
  
  # The rest is done via UJS.
  # See app/views/blog_posts/create.js
