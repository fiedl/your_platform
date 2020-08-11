<template lang="haml">
  %div.w-100.create_post_form
    .input-group
      %vue-wysiwyg{'ref': "wysiwyg", ':placeholder': "placeholder", 'v-model': "post.text", class: 'form-control', '@input': "on_input", ':editable': "submitting ? false : true"}
      .buttons_bottom
        .buttons
          %a.btn.btn-primary.btn-icon{'v-if': "post.id && (post.text.length > 10)", 'v-html': "send_icon", title: "Nachricht posten", ':disabled': "submitting ? true : false", '@click': "submit_post", ':class': "submitting ? 'disabled' : ''"}
          %a.btn.btn-white.btn-icon{'v-html': "camera_icon", title: "Bild hinzufügen", ':disabled': "submitting ? true : false", ':class': "submitting ? 'disabled' : ''"}
    .error.text-truncate.mt-2{'v-if': "error", 'v-text': "error"}
</template>

<script lang="coffee">
  Api = require('../api.coffee').default

  CreatePostForm =
    props: ['placeholder', 'redirect_to_url', 'initial_post', 'camera_icon', 'send_icon', 'parent_page', 'sent_via']
    data: ->
      post: @initial_post || {id: null, text: "", attachments: []}
      submitting: false
      creating_draft: false
      error: null
      draft_saved_message_timeout_handler: null
    methods:
      on_input: ->
        if @post.text.length > 10 and not @post.id and not @creating_draft
          @create_draft()
        else if @post.id
          clearTimeout @draft_saved_message_timeout_handler if @draft_saved_message_timeout_handler
          @draft_saved_message_timeout_handler = setTimeout @save_draft, 2000
      create_draft: ->
        component = this
        @creating_draft = true
        Api.post "/posts",
          data:
            parent_page_id: @parent_page && @parent_page.id
            sent_via: @sent_via
            post: @post
          error: (request, status, error)->
            component.error = request.responseText
          success: (new_post)->
            component.post.id = new_post.id
            component.creating_draft = false
      save_draft: ->
        component = this
        Api.put "/posts/#{@post.id}",
          data:
            post: @post
          error: (request, status, error)->
            component.error = request.responseText
      submit_post: ->
        component = this
        @submitting = true
        Api.post "/posts/#{@post.id}/publish",
          data:
            post: @post
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
        @$refs.wysiwyg.reset()
        @submitting = false
        @error = null
        @creating_draft = false

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
</style>