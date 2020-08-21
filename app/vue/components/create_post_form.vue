<template lang="haml">
  %div.w-100.create_post_form
    %vue-dropzone{':options': "dropzone_options", ':useCustomSlot': "true", id: "create_post", 'ref': "dropzone"}
      .input-group.w-100.mb-2{'v-if': "(!parent) && show_submit_button"}
        %span.input-group-text An:
        %vue-group-select{placeholder: "Empfänger-Gruppen", 'v-model': "post.parent_groups", multiple: true, ':initial_options': "suggested_groups", '@input': "save_draft"}
      .input-group
        %vue-wysiwyg{'ref': "wysiwyg", ':placeholder': "placeholder || default_placeholder", 'v-model': "post.text", class: 'form-control', '@input': "on_input", ':editable': "submitting ? false : true"}
        .buttons_bottom
          .buttons
            %a.btn.btn-primary.btn-icon{'v-if': "show_submit_button", 'v-html': "send_icon", title: "Nachricht posten", ':disabled': "submitting ? true : false", '@click': "submit_post", ':class': "submission_enabled ? '' : 'disabled'"}
            %a.btn.btn-white.btn-icon.upload_button{'v-show': "post.id", 'v-html': "camera_icon", title: "Bild hinzufügen", ':disabled': "submitting ? true : false", ':class': "submitting ? 'disabled' : ''"}
    .text-muted.mt-2{'v-if': "uploading == 1"} Bild wird hochgeladen ...
    .text-muted.mt-2{'v-if': "uploading > 1"} Bilder werden hochgeladen ...
    .error.text-truncate.mt-2{'v-if': "error", 'v-text': "error"}
    .text-right
      .ml-auto
        .mt-2.d-inline-block{'v-if': "show_submit_button && show_send_via_email_toggle"}
          %label.form-check.form-switch
            %input.form-check-input{type: 'checkbox', 'v-model': "send_via_email"}
            %span.form-check-label Als E-Mail versenden
        .ml-4.mt-2.d-inline-block{'v-if': "show_submit_button && !publish_on_public_website && show_publish_on_website_toggle"}
          %label.form-check.form-switch
            %input.form-check-input{type: 'checkbox', 'v-model': "post.publish_on_public_website", '@input': "save_draft"}
            %span.form-check-label Post auf unserer öffentlichen Website veröffentlichen
    .images.mt-2.row.row-sm{'v-if': "post.attachments && post.attachments.length > 0"}
      .col-6.col-sm-4{'v-for': "attachment in post.attachments", ':key': "attachment.id"}
        .image.form-imagecheck.mb-2
          .remove_button.btn.btn-white.btn-icon{'@click': "remove_attachment(attachment)", title: "Bild entfernen"}
            %i.fa.fa-trash
          %img.form-imagecheck-image{':src': "attachment.file.medium.url"}

</template>

<script lang="coffee">
  Api = require('../api.coffee').default
  Vue = require('vue').default
  VueDropzone = require('vue2-dropzone').default

  Vue.component 'vue-dropzone', VueDropzone


  CreatePostForm =
    props: ['placeholder', 'redirect_to_url', 'initial_post', 'camera_icon', 'send_icon', 'parent_page', 'sent_via', 'parent_event', 'publish_on_public_website', 'show_publish_on_website_toggle', 'suggested_groups', 'parent_group', 'show_send_via_email_toggle']
    data: ->
      component = this
      {
        post: @initial_post || {
          id: null,
          text: "",
          attachments: [],
          publish_on_public_website: @publish_on_public_website,
          parent_groups: (if @parent_group then [@parent_group] else [])
        }
        send_via_email: false
        submitting: false
        updating: false
        creating_draft: false
        error: null
        uploading: 0
        draft_saved_message_timeout_handler: null
        dropzone_options:
          url: "/api/v1/attachments"
          method: 'post'
          acceptedFiles: 'image/*'
          clickable: '.upload_button'
          id: "create_post"
          paramName: 'attachment[file]'
          createImageThumbnails: false
          error: (file, msg)->
            component.error = msg
            component.uploading -= 1
          sending: (event, xhr, data)->
            data.append 'authenticity_token', $('meta[name=csrf-token]').attr('content')
            data.append 'post_id', component.post.id
            component.error = null
            component.uploading += 1
          success: (file, new_attachment)->
            component.uploading -= 1
            component.error = null
            component.post.attachments.push(new_attachment)
      }
    created: ->
      if not @post.id and not @creating_draft
        @create_draft()
    methods:
      on_input: ->
        if @post.id
          clearTimeout @draft_saved_message_timeout_handler if @draft_saved_message_timeout_handler
          @draft_saved_message_timeout_handler = setTimeout @save_draft, 2000
        else if not @creating_draft
          @create_draft()
      create_draft: ->
        component = this
        @creating_draft = true
        Api.post "/posts",
          data:
            parent_page_id: @parent_page && @parent_page.id
            parent_event_id: @parent_event && @parent_event.id
            parent_group_id: @parent_group && @parent_group.id
            sent_via: @sent_via
            post: @post
          error: (request, status, error)->
            component.error = request.responseText
          success: (new_post)->
            component.post.id = new_post.id
            component.creating_draft = false
      save_draft: ->
        component = this
        if component.post.id and not component.updating
          component.updating = true
          Api.put "/posts/#{component.post.id}",
            data:
              post: component.post
              parent_group_ids: component.post.parent_groups && (component.post.parent_groups.map (group) -> group.id)
            error: (request, status, error)->
              component.error = request.responseText
              component.updating = false
            success: ->
              component.updating = false
      submit_post: ->
        component = this
        @submitting = true
        Api.post "/posts/#{@post.id}/publish",
          data:
            post: @post
            send_via_email: @send_via_email
            parent_group_ids: component.post.parent_groups && (component.post.parent_groups.map (group) -> group.id)
          error: (request, status, error)->
            component.error = request.responseText
            component.submitting = false
          success: (new_post)->
            component.$root.$emit 'add_post', new_post
            component.reset()
      reset: ->
        @post.id = null
        @post.text = ""
        @post.attachments = []
        @post.publish_on_public_website = false
        @post.parent_groups = (if @parent_group then [@parent_group] else [])
        @$refs.wysiwyg.reset()
        @submitting = false
        @error = null
        @creating_draft = false
      remove_attachment: (attachment)->
        component = this
        @post.attachments.splice(@post.attachments.indexOf(attachment), 1)
        Api.delete "/attachments/#{attachment.id}",
          error: (request, status, error)->
            component.error = request.responseText
      get_parent: ->
        @parent_page || @parent_event || @parent_group
      get_parent_type: ->
        "Page" if @parent_page
        "Event" if @parent_event
        "Group" if @parent_group
    computed:
      parent: ->
        # We need this because computed properties are not available during data init.
        @get_parent()
      parent_type: ->
        @get_parent_type()
      show_submit_button: ->
        @post.id && ((@post.text && @post.text.length > 10) || @post.attachments.length > 0)
      default_placeholder: ->
        if @post.publish_on_public_website
          "Öffentlich posten"
        else
          "Nachricht posten"
      submission_enabled: ->
        not (@submitting || @updating || @creating_draft) and (@parent || (@post.parent_groups && @post.parent_groups.length > 0)) and (@uploading == 0)

  export default CreatePostForm
</script>

<style lang="sass">
  .create_post_form
    .ProseMirror
      outline: 0

    p
      margin-bottom: 0

    .btn-primary
      color: white
      svg
        stroke: white

    .buttons_bottom
      position: relative
      .buttons
        position: absolute
        bottom: 0
        right: 0
        display: inline-flex
        .btn
          border-top-left-radius: 0
          border-bottom-left-radius: 0
        .btn:not(:last-child)
          border-top-right-radius: 0
          border-bottom-right-radius: 0
    .error
      color: red

    .image
      position: relative
      .remove_button
        position: absolute
        left: 10px
        top: 10px

    .dz-preview
      display: none
</style>