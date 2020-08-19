<template lang="haml">
  %div.comments
    %ul.list-unstyled.comments
      %li.d-flex.mt-4{'v-for': "comment in comments"}
        %div
          %vue-avatar.mr-3{':user': "comment.author"}
        .flex-fill
          %strong.h4{':title': "format_datetime(comment.created_at)"}
            %a{':href': "'/users/' + comment.author.id"} {{ comment.author.title }}
          %span{'v-html': "sanitize(comment.text)"}
    .error.text-danger{'v-if': "error"} {{ error.first(100) }}
    .add_comment{'v-if': "can_comment"}
      %small.mt-3{'v-if': "! adding_comment"}
        %a{'@click': "add_comment"} Antworten
      %div.mt-3{'v-if': "adding_comment && !submitting"}
        .input-group
          %vue-wysiwyg.form-control{'ref': "wysiwyg", placeholder: "Antwort schreiben", 'v-model': "new_comment.text", ':editable': "submitting ? false : true", ':autofocus': "true"}
          %a.btn.btn-primary.btn-icon.c-white{'v-html': "send_icon", title: "Antwort posten", ':disabled': "submitting ? true : false", '@click': "submit_comment", ':class': "submitting ? 'disabled' : ''"}
</template>

<script lang="coffee">
  Api = require('../api.coffee').default
  sanitize_html = require('sanitize-html')
  moment = require('moment')

  Comments =
    props: ['initial_comments', 'can_comment', 'parent_post', 'send_icon', 'current_user']
    data: ->
      comments: @initial_comments
      adding_comment: false
      new_comment: {id: null, text: null, author: @current_user}
      submitting: false
      error: null
    created: ->
      @reset()
    methods:
      add_comment: ->
        @adding_comment = true
      submit_comment: ->
        component = this
        @submitting = true
        @error = null
        component.comments.push(component.new_comment)
        Api.post '/comments',
          data:
            comment: @new_comment
            parent_post_id: @parent_post.id
          error: (request, status, error)->
            component.error = request.responseText
            component.reset()
          success: (new_comment)->
            component.new_comment.id = new_comment.id
            component.new_comment.created_at = new_comment.created_at
            component.comments.pop()
            component.comments.push(Object.assign({}, component.new_comment))
            component.reset()
      reset: ->
        @$refs.wysiwyg && @$refs.wysiwyg.reset()
        @new_comment.id = null
        @new_comment.text = null
        @new_comment.author = @current_user
        @adding_comment = false
        @submitting = false
      sanitize: (html)->
        sanitize_html html
      format_datetime_relative: (datetime)->
        moment(datetime).locale('de').fromNow()
      format_datetime: (datetime)->
        moment(datetime).locale('de').format('dd, DD.MM.YYYY, H:mm')

  export default Comments
</script>

<style lang="sass">
  .comments
    .ProseMirror
      outline: 0

    p
      margin-bottom: 0

    .btn-primary
      color: white
      svg
        stroke: white

    a
      cursor: pointer
</style>