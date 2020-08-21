<template lang="haml">
  %div.new_documents_form
    %vue-dropzone{':options': "dropzone_options", id: "attachment", '@dragenter': "suggesting_drop = true", '@dragleave': "suggesting_drop = false", ':useCustomSlot': "true"}
      .card
        .card-body
          .text-center
            .btn.btn-primary.mt-4.mb-4.upload-click-trigger
              %i.fa.fa-plus
              %span Dokumente hinzufügen

            .text-muted.mt-2{'v-if': "uploading == 1"} Dokument wird hochgeladen ...
            .text-muted.mt-2{'v-if': "uploading > 1"} {{ uploading }} Dokumente werden hochgeladen ...

        %div{'v-if': "post.attachments && post.attachments.length > 0"}
          %table.table.table-vcenter.card-table
            %thead
              %tr
                %th.w-5
                %th Dokument-Titel
                %th.d-none.d-md-table-cell Autor
                %th.d-none.d-md-table-cell Beschreibung
                %th.w-1 Löschen
            %tbody
              %tr{'v-for': "attachment in post.attachments", ':key': "attachment.id"}
                %td.w-5
                  .thumb
                    %a{':href': "attachment.file_path"}
                      %img{':src': "attachment.file.thumb.url"}
                %td
                  %input.form-control{type: 'text', 'v-model': "attachment.title", '@change': "update_attachment(attachment)"}
                %td.d-none.d-md-table-cell.author
                  %vue-user-select{placeholder: "Dokument-Autor", 'v-model': "attachment.author", '@input': "update_attachment(attachment)"}
                %td.d-none.d-md-table-cell
                  %input.form-control.mb-0{placeholder: "Beschreibung (optional)", 'v-model': "attachment.description", '@change': "update_attachment(attachment)"}
                %td.w-1
                  %i.fa.fa-trash.fa-2x{'@click': "remove(attachment)"}

        .card-body
          .row.mt-4
            .col-md-6.mb-3
              .form-label.required Leserechte
              .mb-2
                %vue-group-select{placeholder: "Gruppen mit Leserechten ausstatten", 'v-model': "post.parent_groups", ':multiple': "true", ':initial_options': "current_user_groups", required_ability: 'create_post', '@input': "update_parent_groups"}
              -#      .col-md-6.mb-3
              -#        .form-label Tags
              -#        %vue_editable_tags{':initial_tags': ActsAsTaggableOn::Tag.all.to_json}

          .form-label Nachricht
          %vue-wysiwyg.form-control{'v-model': "post.text", placeholder: "Nachricht (optional)", '@input': "on_text_input", editable: true}
          .text-muted{'v-if': "draft_saved"} Entwurf gespeichert.

          .error.mt-4{'v-if': "error"}
            %strong Fehler
            .text-truncate {{ error }}

        .card-footer
          .d-sm-flex.align-items-center
            %a.btn.btn-link{'@click': "cancel"} Abbrechen
            %label.form-check.form-switch.ml-auto.mr-3
              %input.form-check-input{type: 'checkbox', 'v-model': "send_via_email"}
              %span.form-check-label Als E-Mail verschicken
            %button.btn.btn-primary{type: 'submit', '@click': "submit_post", ':disabled': "! submission_enabled"} Dokumente posten

</template>

<script lang="coffee">
  Api = require('../api.coffee').default
  Vue = require('vue').default
  VueDropzone = require('vue2-dropzone').default
  Vue.component 'vue-dropzone', VueDropzone

  NewDocumentsForm =
    props: ['initial_post', 'current_user_groups', 'sent_via']
    data: ->
      component = this
      {
        post: @initial_post || {id: null, text: null, attachments: []}
        send_via_email: false
        draft_saved_message_timeout_handler: null
        draft_saved: false
        suggesting_drop: false
        uploading: 0
        error: null
        submitting: false
        updating_parent_groups: false
        dropzone_options:
          url: -> "/api/v1/posts/#{component.post.id}/attachments"
          method: 'post'
          paramName: "attachment[file]"
          clickable: '.upload-click-trigger'
          acceptedFiles: "application/pdf,*document*"
          error: (file, msg)->
            component.error = msg
            component.uploading -= 1
          sending: (event, xhr, data)->
            component.error = null
            component.uploading += 1
            data.append 'authenticity_token', $('meta[name=csrf-token]').attr('content')
          success: (file, new_attachment)->
            component.uploading -= 1
            component.error = null
            component.post.attachments.push(new_attachment)
      }
    methods:
      on_text_input: ->
        @draft_saved = false
        clearTimeout @draft_saved_message_timeout_handler if @draft_saved_message_timeout_handler
        @draft_saved_message_timeout_handler = setTimeout @save_draft, 5000
      save_draft: ->
        component = this
        $.ajax
          url: "/posts/#{component.post.id}"
          method: 'post'
          data:
            _method: 'put'
            post: component.post
          success: ->
            component.draft_saved = true
          error: (request, status, error)->
            component.error = request.responseText
      remove: (attachment)->
        component = this
        @post.attachments.splice(@post.attachments.indexOf(attachment), 1)
        Api.delete "/attachments/#{attachment.id}",
          error: (request, status, error)->
            component.error = request.responseText
      update_attachment: (attachment)->
        component = this
        Api.put "/attachments/#{attachment.id}",
          data:
            attachment:
              title: attachment.title
              author_user_id: attachment.author.id
              description: attachment.description
          error: (request, status, error)->
            component.error = request.responseText
      update_parent_groups: ->
        component = this
        Api.put "/posts/#{@post.id}",
          data:
            parent_group_ids: @post.parent_groups.map (parent_group) -> parent_group.id
          error: (request, status, error)->
            component.error = request.responseText
          complete: ->
            component.updating_parent_groups = false
      cancel: ->
        component = this
        $.ajax
          url: "/posts/#{component.post.id}"
          method: 'delete'
        window.location = "/documents"
      submit_post: ->
        component = this
        @submitting = true
        Api.post "/posts/#{@post.id}/publish",
          data:
            post: @post
            send_via_email: @send_via_email
          error: (request, status, error)->
            component.error = request.responseText
            component.submitting = false
          success: (new_post)->
            component.$root.$emit 'add_post', new_post
            window.location = "/documents"
    computed:
      submission_enabled: ->
        not (@updating_parent_groups or @uploading > 0 or @submitting)
  export default NewDocumentsForm
</script>

<style lang="sass">
  .card-header
    display: block

  .thumb
    min-width: 50px

  .error
    color: red

  .dz-preview
    display: none

  .new_documents_form
    .ProseMirror
      outline: 0
      min-height: 3em
    p
      margin-bottom: 0


</style>