<template lang="haml">
  %vue-dropzone{':options': "dropzone_options", ':useCustomSlot': "true", id: "update_post", 'ref': "dropzone"}
    .d-flex
      %div.mr-3
        %vue-avatar{':user': "current_post.author"}
      .flex-fill
        %div.post
          %small.float-right.text-right
            %span.text-muted{'v-if': "(current_post.editable) && (!show_single_post)"}
              %a.text-muted{':href': "'/posts/' + post.id", title: "Details ansehen bzw. Post bearbeiten"} Bearbeiten
              %span.ml-1.mr-1= " | "
            %a.text-muted{':href': "'/posts/' + post.id", 'v-text': "format_datetime_relative(current_post.published_at || current_post.sent_at)", ':title': "format_datetime(current_post.published_at || current_post.sent_at)"}
            .mb-4.mt-1.ml-4{'v-if': "!show_single_post"}
              .mb-0{'v-for': "group in current_post.groups"}
                %a.text-muted{':href': "'/groups/' + group.id + '/posts'"} {{ group.name }}
              .mb-0{'v-for': "event in current_post.events"}
                %a.text-muted{':href': "'/events/' + event.id"} {{ event.name }}
          %h4.align-items-center.d-md-flex
            %a.author{':href': "current_post.author.path", 'v-if': "current_post.author.path"} {{ current_post.author.title }}
            %span.author{'v-else': true} {{ current_post.author.title }}
            %span.badge.bg-blue.ml-2{'v-if': "current_post.publish_on_public_website && show_public_badges", title: "Auf öffentlichem Internetauftritt veröffentlicht", ':data-toggle': "current_post.can_update_publish_on_public_website ? 'dropdown' : ''"} Öffentlich
            %span.badge.bg-gray.ml-2{'v-if': "!current_post.publish_on_public_website && show_public_badges", title: "Nur für Bundesbrüder sichtbar, nicht aber auf dem öffentlichem Internetauftritt veröffentlicht.", ':data-toggle': "current_post.can_update_publish_on_public_website ? 'dropdown' : ''"} Nicht öffentlich
            .dropdown-menu{'v-if': "current_post.can_update_publish_on_public_website"}
              %a.dropdown-item{':class': "current_post.publish_on_public_website ? 'active' : ''", '@click': "set_publish_on_public_website(true)"} Auf öffentlicher Website veröffentlichen
              %a.dropdown-item{':class': "current_post.publish_on_public_website ? '' : 'active'", '@click': "set_publish_on_public_website(false)"} Nicht auf öffentlicher Website veröffentlichen
          .error.color-danger.mt-2.mb-4{'v-if': "error", 'v-text': "error.first(100)"}
          %vue-editable{'ref': "post_text", ':initial-value': "current_post.text", type: 'wysiwyg', ':editable': "editable", 'input_class': "form-control", ':url': "'/posts/' + post.id", 'param-key': "post[text]"}
          .text-muted.mt-2{'v-if': "uploading_images == 1"} Bild wird hochgeladen ...
          .text-muted.mt-2{'v-if': "uploading_documents == 1"} Dokument wird hochgeladen ...
          .text-muted.mt-2{'v-if': "uploading_images > 1"} Bilder werden hochgeladen ...
          .text-muted.mt-2{'v-if': "uploading_documents > 1"} Dokument werden hochgeladen ...
          %vue-pictures{ref: "pictures", 'v-if': "current_post.attachments && current_post.attachments.length > 0", ':attachments': "images(current_post.attachments)", ':editable': "editable"}
          %vue-attachments{ref: "attachments", 'v-if': "current_post.attachments && current_post.attachments.length > 0", ':attachments': "non_images(current_post.attachments)", ':editable': "editable"}
        %vue-comments{':parent_post': "post", ':initial_comments': "post.comments", ':send_icon': "send_icon", ':current_user': "current_user", ':can_comment': "post.can_comment", ':key': "post.id"}
</template>

<script lang="coffee">
  moment = require('moment')
  Api = require('../api.coffee').default
  sanitize_html = require('sanitize-html')
  Vue = require('vue').default
  VueDropzone = require('vue2-dropzone')

  Vue.component 'vue-dropzone', VueDropzone

  Post =
    props: ['post', 'show_public_badges', 'send_icon', 'current_user', 'show_single_post']
    data: ->
      component = this
      {
        current_post: @post
        error: null
        uploading_images: 0
        uploading_documents: 0
        dropzone_options:
          url: "/api/v1/attachments"
          method: 'post'
          clickable: false
          id: "update_post"
          paramName: 'attachment[file]'
          createImageThumbnails: false
          error: (file, msg)->
            component.error = msg
            if file.type.includes('image')
              component.uploading_images -= 1
            else
              component.uploading_documents -= 1
          sending: (event, xhr, data)->
            data.append 'authenticity_token', $('meta[name=csrf-token]').attr('content')
            data.append 'post_id', component.post.id
            component.error = null
            if event.type.includes('image')
              component.uploading_images += 1
            else
              component.uploading_documents += 1
          success: (file, new_attachment)->
            if file.type.includes('image')
              component.uploading_images -= 1
            else
              component.uploading_documents -= 1
            component.error = null
            component.current_post.attachments.push(new_attachment)
      }
    mounted: ->
      @$refs.dropzone.disable() unless (@post.editable && @show_single_post)
    methods:
      format_datetime_relative: (datetime)->
        moment(datetime).locale('de').fromNow()
      format_datetime: (datetime)->
        moment(datetime).locale('de').format('dd, DD.MM.YYYY, H:mm')
      set_publish_on_public_website: (setting)->
        component = this
        @current_post.publish_on_public_website = setting
        Api.put "/posts/#{@post.id}/public_website_publications",
          data:
            post: @current_post
          error: (request, status, error)->
            component.error = request.responseText.first(100)
            component.current_post.publish_on_public_website = !setting
      images: (attachments)->
        attachments.filter (attachment)-> attachment.content_type.includes("image")
      non_images: (attachments)->
        attachments.filter (attachment)-> (!attachment.content_type.includes("image"))
      editables: ->
        [@$refs.post_text, @$refs.attachments].filter((editable) -> editable)
      editBox: ->
        @$parent.editBox()
    computed:
      editable: ->
        @post.editable && @show_single_post
  export default Post
</script>

<style lang="sass">
  .dz-preview
    display: none
</style>