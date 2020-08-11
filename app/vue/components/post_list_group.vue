<template lang="haml">
  %ul.card-list-group.list-group
    .list-group-item.py-4{'v-for': "post in processed_posts"}
      .d-flex
        %div.mr-3
          %vue-avatar{':user': "post.author"}
        .flex-fill
          %div
            %small.float-right.text-muted{'v-text': "post.published_at_relative", ':title': "format_datetime(post.published_at)"}
            %h4
              %a{':href': "post.author.path", 'v-if': "post.author.path"} {{ post.author.title }}
              %span{'v-else': true} {{ post.author.title }}
            %div{'v-html': "post.text"}

</template>

<script lang="coffee">
  moment = require('moment')

  PostListGroup =
    props: ['posts']
    data: ->
      processed_posts: @posts
    created: ->
      @process_posts()
      setInterval @process_posts, 60000
    methods:
      format_datetime_relative: (datetime)->
        moment(datetime).locale('de').fromNow()
      format_datetime: (datetime)->
        moment(datetime).locale('de').format('dd, DD.MM.YYYY, H:mm')
      process_posts: ->
        component = this
        @processed_posts = @posts.map (post)->
          post.published_at_relative = component.format_datetime_relative(post.published_at)
          post

  export default PostListGroup
</script>