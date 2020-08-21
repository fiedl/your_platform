<template lang="haml">
  %ul.card-list-group.list-group
    .list-group-item.py-4{'v-for': "post in processed_posts", ':key': "post.id"}
      .d-flex
        %div.mr-3
          %vue-avatar{':user': "post.author"}
        .flex-fill
          %div
            %small.float-right.text-right
              %a.text-muted{':href': "'/posts/' + post.id", 'v-text': "post.published_at_relative", ':title': "format_datetime(post.published_at || post.sent_at)"}
              .mb-4.mt-1.ml-4{'v-if': "groups.length > 1"}
                .mb-0{'v-for': "group in post.groups"}
                  %a.text-muted{':href': "'/groups/' + group.id + '/posts'"} {{ group.name }}
            %h4.align-items-center.d-flex
              %a{':href': "post.author.path", 'v-if': "post.author.path"} {{ post.author.title }}
              %span{'v-else': true} {{ post.author.title }}
              %span.badge.bg-blue.ml-2{'v-if': "post.publish_on_public_website && show_public_badges", title: "Auf öffentlichem Internetauftritt veröffentlicht", ':data-toggle': "post.can_update_publish_on_public_website ? 'dropdown' : ''"} Öffentlich
              %span.badge.bg-gray.ml-2{'v-if': "!post.publish_on_public_website && show_public_badges", title: "Nur für Bundesbrüder sichtbar, nicht aber auf dem öffentlichem Internetauftritt veröffentlicht.", ':data-toggle': "post.can_update_publish_on_public_website ? 'dropdown' : ''"} Nicht öffentlich
              .dropdown-menu{'v-if': "post.can_update_publish_on_public_website"}
                %a.dropdown-item{':class': "post.publish_on_public_website ? 'active' : ''", '@click': "set_publish_on_public_website(post, true)"} Auf öffentlicher Website veröffentlichen
                %a.dropdown-item{':class': "post.publish_on_public_website ? '' : 'active'", '@click': "set_publish_on_public_website(post, false)"} Nicht auf öffentlicher Website veröffentlichen
            .error.mt-2.mb-4{'v-if': "post.error_message", 'v-text': "post.error_message"}
            %div{'v-html': "sanitize(post.text)"}
            %vue-pictures{'v-if': "post.attachments && post.attachments.length > 0", ':attachments': "images(post.attachments)"}
            %vue-attachments{'v-if': "post.attachments && post.attachments.length > 0", ':attachments': "non_images(post.attachments)"}
          %vue-comments{':parent_post': "post", ':initial_comments': "post.comments", ':send_icon': "send_icon", ':current_user': "current_user", ':can_comment': "post.can_comment", ':key': "post.id"}
</template>

<script lang="coffee">
  moment = require('moment')
  Api = require('../api.coffee').default
  sanitize_html = require('sanitize-html')

  PostListGroup =
    props: ['posts', 'show_public_badges', 'send_icon', 'current_user']
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
      images: (attachments)->
        attachments.filter (attachment)-> attachment.content_type.includes("image")
      non_images: (attachments)->
        attachments.filter (attachment)-> (!attachment.content_type.includes("image"))
      sanitize: (html)->
        sanitize_html html,
          allowedTags: sanitize_html.defaults.allowedTags.concat(['blockquote', 'q'])
      process_posts: ->
        component = this
        @processed_posts = @current_posts.map (post)->
          post.published_at_relative = component.format_datetime_relative(post.published_at || post.sent_at)
          post
      add_post: (post)->
        @current_posts.unshift(post)
        @process_posts()
      set_publish_on_public_website: (post, setting)->
        component = this
        post.publish_on_public_website = setting
        Api.put "/posts/#{post.id}/public_website_publications",
          data:
            post: post
          error: (request, status, error)->
            post.error_message = request.responseText.first(100)
            post.publish_on_public_website = !setting
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