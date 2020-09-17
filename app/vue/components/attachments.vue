<template lang="haml">
  %div
    .row.mb-n3
      .col-md-6.row.row-sm.mb-3.align-items-center{'v-for': "attachment in current_attachments", ':key': "attachment.id"}
        %a.col-auto.thumb{':href': "attachment.file_path", target: '_blank'}
          %img{':src': "attachment.file.thumb.url"}
        .col
          %a{':href': "attachment.file_path", target: '_blank'} {{ attachment.title }}
          .text-muted.d-block.mt-n1.author {{ attachment.author_title }}
          %span{'v-if': "editable && editing"}
            .remove_button.btn.btn-white.btn-sm{'@click': "remove_attachment(attachment)"}
              %i.fa.fa-trash
              Datei entfernen
    .error.color-danger{'v-if': "error", 'v-text': "error.first(100)"}
</template>

<script lang="coffee">
  Api = require('../api.coffee').default

  Attachments =
    props: ['attachments', 'editable']
    data: ->
      current_attachments: @attachments
      editing: false
      error: null
    methods:
      edit: ->
        @editing = true
      waitForSave: ->
        @editing = false
      save: ->
        @editing = false
      editables: ->
        [this]
      editBox: ->
        @$parent.editBox()
      remove_attachment: (attachment)->
        component = this
        @current_attachments.splice(@current_attachments.indexOf(attachment), 1)
        Api.delete "/attachments/#{attachment.id}",
          error: (request, status, error)->
            component.error = request.responseText
    watch:
      attachments: (new_attachments, old_attachments)->
        for attachment in new_attachments
          @current_attachments.push(attachment) unless old_attachments.includes(attachment)

  export default Attachments
</script>

<style lang="sass">
  .thumb img
    width: 3em
    border: 1px solid grey
    border-radius: 3px
</style>