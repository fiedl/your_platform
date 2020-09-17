<template lang="haml">
  %ul.card-list-group.list-group
    .list-group-item.py-4{'v-for': "post in processed_posts", ':key': "post.id"}
      %vue-post{':post': "post", ':show_public_badges': "show_public_badges", ':send_icon': "send_icon", ':current_user': "current_user", ':show_single_post': "show_single_post"}
</template>

<script lang="coffee">
  moment = require('moment')
  Api = require('../api.coffee').default
  sanitize_html = require('sanitize-html')

  PostListGroup =
    props: ['posts', 'show_public_badges', 'send_icon', 'current_user', 'sent_via', 'show_single_post']
    data: ->
      current_posts: @posts
      processed_posts: @posts
    created: ->
      @process_posts()
      setInterval @process_posts, 60000
      @$root.$on 'add_post', @add_post
    methods:
      sanitize: (html)->
        sanitize_html html,
          allowedTags: sanitize_html.defaults.allowedTags.concat(['blockquote', 'q', 'h1', 'h2', 'h3', 'h4', 'iframe', 'div'])
          allowedIframeHostnames: ['www.youtube.com']
          allowedAttributes: {
            a: ['href', 'name', 'target', 'class'],
            img: ['src'],
            iframe: ['src']
            div: ['class']
          }
      process_posts: ->
        component = this
        @processed_posts = @current_posts
      add_post: (post)->
        if (!@sent_via) || (@sent_via == post.sent_via)
          @current_posts.unshift(post)
          @process_posts()
      editables: ->
        @$children.map((child) -> child.editables()).flat()
      editBox: ->
        @$parent.editBox() if @$parent.editBox
    computed:
      groups: ->
        @current_posts.map( (post) -> post.groups ).flat().unique()

  export default PostListGroup
</script>

<style lang="sass">
  a.dropdown-item
    cursor: pointer
  .error
    color: red
</style>