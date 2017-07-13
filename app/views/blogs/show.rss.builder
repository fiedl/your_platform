generate_rss_feed xml, root_element: @blog, items: @blog.blog_entries.visible_to(current_user)
