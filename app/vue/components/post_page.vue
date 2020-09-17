<template lang="haml">
  %div
    .mb-3.ml-1.d-flex
      .page-title
        %vue-editable{ref: 'subject', ':initial-value': "post.subject", placeholder: "Betreff dieses Posts", input_class: 'form-control', ':url': "'/posts/' + post.id", 'param-key': "post[subject]", ':editable': "post.editable"}
      .ml-auto
        .archive_tool{'v-show': "ready"}
          %a.btn.btn-white.mr-1.has_tooltip{title: "Der Post wird nicht mehr angezeigt, außer, wenn man ihn über einen Direkt-Link aufruft. Der Post wird also \"fast\" gelöscht. Aber wir heben eine Archiv-Kopie auf, damit Links in E-Mails etc. nicht ins Leere laufen.", 'data-placement': "bottom", '@click': "archive", 'v-show': "!post.archived_at"}
            %span{'v-html': "trash_icon"}
            Post archivieren
          %a.btn.btn-white.mr-1.has_tooltip{title: "Der Post ist im Moment archiviert. Die Wiederherstellung macht den Post wieder sichtbar.", 'data-placement': "bottom", '@click': "restore", 'v-show': "post.archived_at"}
            Post wiederherstellen
    .row
      .error.color-danger.mb-3{'v-if': "error", 'v-text': "error.first(100)"}
      .col-sm-8
        .card
          .card-body
            %vue-post-list-group{ref: 'posts', ':posts': "[current_post]", ':current_user': "current_user", show_single_post: true, ':send_icon': "send_icon"}
      .col-sm-4
        %div
          .card
            .card-header
              %h3.mb-0 Zielgruppe
            .card-body
              %div{'v-if': "editing"}
                %label.form-label Leserechte
                %vue-group-select{placeholder: "Gruppen auswählen, deren Mitglieder diesen Post lesen dürfen", multiple: true, 'v-model': "current_post.groups", '@input': "submit_update"}
              %div{'v-else': true}
                .mb-2.d-flex.align-items-center{'v-for': "group in current_post.groups"}
                  .mr-2
                    %vue-avatar.avatar-sm{':group': "group"}
                  %a.text-link{':href': "'/groups/' + group.id + '/members'", 'v-text': "group.title"}
              .mt-3
                %label.form-check.form-switch
                  %input.form-check-input{type: 'checkbox', 'v-model': "current_post.publish_on_public_website", '@change': "submit_update"}
                  %span.form-check-label Auf öffentlicher Website veröffentlichen
              .mt-3
                %label.form-label Veröffentlicht am
                %vue-editable{ref: 'published_at', type: 'datetime', ':editable': "current_post.editable", input_class: 'form-control', ':initial-value': "format_datetime(current_post.published_at)", ':initial-object': "post", ':url': "'/posts/' + post.id", 'param-key': "post[published_at]"}

          %div{'v-if': "editing && current_post.sent_at"}
            .alert.alert-warning Dieser Post wurde bereits per E-Mail verschickt. Du kannst den Post zwar noch auf der Plattform bearbeiten. Der Post dadurch aber nicht erneut per E-Mail versandt.
          %div{'v-if': "ready"}
            .card{'v-if': "current_post.sent_at"}
              .card-header
                %h3.mb-0 Sendebericht
              .card-body
                %label.form-label Versandt am
                %span{'v-text': "format_datetime(current_post.sent_at)"}
                %div
                  %div{'v-if': "post.sent_deliveries && post.sent_deliveries.length > 0"}
                    %label.form-label.mt-3 Zugestellt an
                      .avatar-list.avatar-list-stacked.d-block
                        %a.avatar{'v-for': "delivery in post.sent_deliveries", ':href': "'/users/' + delivery.user_id", ':title': "delivery.user.title"}
                          %vue-avatar{':user': "delivery.user"}
                  %div{'v-if': "post.failed_deliveries && post.failed_deliveries.length > 0"}
                    %label.form-label.mt-3 Konnte nicht zustellen an:
                      .avatar-list.avatar-list-stacked.d-block
                        %a.avatar{'v-for': "delivery in post.failed_deliveries", ':href': "'/users/' + delivery.user_id", ':title': "delivery.user.title"}
                          %vue-avatar{':user': "delivery.user"}
            .card{'v-if': "!current_post.sent_at && !current_post.archived_at && current_post.published_at"}
              .card-header
                %h3.mb-0 Per E-Mail versenden
              .card-body
                Dieser Post wurde noch nicht per E-Mail verschickt.
                %a.btn.btn-primary.mt-2{'href': '#', '@click': "deliver"}
                  %span{'v-html': "mail_icon"}
                  %span{'v-text': "'Per E-Mail senden an: ' + group_names"}

        -//# TODO: Ausprobieren, wie die UI sich für Event-Posts macht.
        -//# TODO: Attachments
        -//# TODO: published scope
        -//# TODO: subject in posts form

</template>

<script lang="coffee">
  moment = require('moment')
  Api = require('../api.coffee').default
  sanitize_html = require('sanitize-html')

  PostPage =
    props: ['post', 'mail_icon', 'edit_icon', 'trash_icon', 'send_icon', 'current_user']
    data: ->
      editing: false
      submitting: false
      current_post: @post
      waiting_for_submission: false
      error: null
    mounted: ->
      $(".has_tooltip").tooltip()
    methods:
      edit: ->
        @editing = true
      waitForSave: ->
        @editing = false
        @waiting_for_submission = true
      save: ->
        @editing = false
        @waiting_for_submission = false
        @submit_update()
      editables: ->
        [this.$refs.subject, this.$refs.published_at, this.$refs.posts.editables(), this].flat()
      editBox: ->
        @$parent.editBox()
      format_datetime: (datetime)->
        moment(datetime).locale('de').format('dd, DD.MM.YYYY, H:mm')
      archive: ->
        @current_post.archived_at = @format_datetime(moment())
        @submit_update()
        $(".has_tooltip").tooltip()
      restore: ->
        @current_post.archived_at = null
        @submit_update()
        $(".has_tooltip").tooltip()
      submit_update: ->
        component = this
        component.error = null
        component.submitting = true
        Api.put "/posts/#{@post.id}",
          data:
            parent_group_ids: @current_post.groups.map (group)-> group.id
            post:
              archived_at: @current_post.archived_at
              publish_on_public_website: @current_post.publish_on_public_website
          error: (request, status, error)->
            component.error = request.responseText
            component.submitting = false
          success: ->
            component.submitting = false
      deliver: ->
        component = this
        component.error = null
        component.submitting = true
        Api.post "/posts/#{@post.id}/deliver",
          error: (request, status, error)->
            component.error = request.responseText
            component.submitting = false
          success: (result)->
            component.submitting = false
            component.current_post.sent_at = result.sent_at
    computed:
      group_names: ->
        @current_post.groups.map((group) -> group.name).join(", ")
      ready: ->
        !@editing && !@waiting_for_submission && !@submitting

  export default PostPage
</script>

<style lang="sass">
</style>