comments_ul = $("ul.comments-for-<%= @comment.commentable.id %>")
new_comment_li = comments_ul.find('li').last()
rendered_comment = "<%= j content_tag(:li) { render(partial: 'comments/comment', locals: {comment: @comment}) } %>"

# Insert the rendered comment.
new_comment_li.before(rendered_comment)

# Clear the new-comment form.
new_comment_li.find('textarea').val('')
new_comment_li.find('.comment-tools').hide()
new_comment_li.find('textarea').focus()