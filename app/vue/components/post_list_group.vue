<template lang="haml">
  %ul.card-list-group.list-group
    .list-group-item.py-4{'v-for': "post in processed_posts"}
      .d-flex
        %div.mr-3
          %vue-avatar{':user': "post.author"}
        .flex-fill
          %div
            %small.float-right{':title': "format_datetime(post.published_at)"}
              %a.text-muted{':href': "'/posts/' + post.id", 'v-text': "post.published_at_relative"}
            %h4.align-items-center.d-flex
              %a{':href': "post.author.path", 'v-if': "post.author.path"} {{ post.author.title }}
              %span{'v-else': true} {{ post.author.title }}
              %span.badge.bg-blue.ml-2{'v-if': "post.publish_on_public_website && show_public_badges", title: "Auf öffentlichem Internetauftritt veröffentlicht"} Öffentlich
            %div{'v-html': "post.text"}
            %vue-pictures{'v-if': "post.attachments && post.attachments.length > 0", ':attachments': "post.attachments"}
</template>

<script lang="coffee">
  moment = require('moment')

  PostListGroup =
    props: ['posts', 'show_public_badges']
    data: ->
      current_posts: @posts
      processed_posts: @posts
    created: ->
      @process_posts()
      setInterval @process_posts, 60000
      @$root.$on 'add_post', @add_post
    methods:
      format_datetime_relative: (datetime)->
        moment(datetime).locale('de').fromNow()
      format_datetime: (datetime)->
        moment(datetime).locale('de').format('dd, DD.MM.YYYY, H:mm')
      process_posts: ->
        component = this
        @processed_posts = @current_posts.map (post)->
          post.published_at_relative = component.format_datetime_relative(post.published_at)
          post
      add_post: (post)->
        @current_posts.unshift(post)
        @process_posts()
  export default PostListGroup
</script>