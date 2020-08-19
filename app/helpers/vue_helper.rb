module VueHelper

  # Display a list of posts and comments with a vue component.
  #
  # show_public_badges: Whether to show a badge indicating whether the
  #   post is to be published on the public website.
  #
  def vue_posts(posts, show_public_badges: false)
    content_tag :vue_post_list_group, "", {
      ':posts': posts.collect { |post|
        post.as_json.merge({
          author: post.author.as_json.merge({
            path: (polymorphic_path(post.author) if can?(:read, post.author))
          }),
          attachments: post.attachments.as_json,
          comments: post.comments.collect { |comment|
            comment.as_json.merge({
              author: comment.author
            })
          },
          can_comment: can?(:create_comment, post),
          groups: (post.parent_groups + [post.group] - [nil]).as_json,
          can_update_publish_on_public_website: can?(:update_public_website_publication, post)
        })
      }.to_json,
      send_icon: send_icon,
      ':current_user': current_user.to_json,
      ':show_public_badges': show_public_badges.to_b.to_json
    }
  end

end