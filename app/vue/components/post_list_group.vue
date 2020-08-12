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
            .images.mt-2.row.row-sm{'v-if': "post.attachments && post.attachments.length > 0"}
              .col-6.col-sm-4{'v-for': "attachment in post.attachments", ':key': "attachment.id"}
                .image.form-imagecheck.mb-2
                  %img.form-imagecheck-image{':src': "attachment.file.medium.url"}

</template>

<script lang="coffee">
  moment = require('moment')

  PostListGroup =
    props: ['posts']
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