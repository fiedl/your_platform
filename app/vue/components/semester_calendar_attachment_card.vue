<template lang="haml">
  %vue-dropzone{':options': "dropzone_options", ':useCustomSlot': "true", ':id': "'semester_calendar_' + semester_calendar.id + '_attachment'"}
    .card.semester_calendar_pdf
      .card-header
        %h3 {{ card_header_title }}
      .card-body
        .existing_attachment{'v-if': "attachment"}
          %a{':href': "attachment.file_path", target: '_blank'}
            %img{':src': "image || attachment.file.medium.url"}
          %small.text-muted{'v-if': "status"} {{ status }}
          %small.text-muted{'v-else': true} Hochgeladen am: {{ uploaded_at }}
        .no_attachment{'v-else': true}
          .text-muted Kein PDF hochgeladen.
        .error{'v-if': "error"} {{ error }}
      .card-footer{'v-if': "editable"}
        %a.btn.btn-white.btn-sm.upload_button{'v-if': "attachment"} Neues PDF hochladen
        %a.btn.btn-white.btn-sm.upload_button{'v-else': true} PDF hochladen
</template>

<script lang="coffee">
  moment = require('moment')
  Vue = require('vue').default
  VueDropzone = require('vue2-dropzone').default

  Vue.component 'vue-dropzone', VueDropzone

  SemesterCalendarAttachmentCard =
    props: ['header', 'semester_calendar', 'corporation', 'term', 'initial_attachment', 'editable']
    data: ->
      component = this
      {
        attachment: @initial_attachment
        status: null
        error: null
        image: null
        dropzone_options:
          url: "/semester_calendars/#{@semester_calendar.id}"
          method: 'put'
          acceptedFiles: 'application/pdf'
          clickable: '.upload_button'
          id: "semester_calendar_#{@semester_calendar.id}_attachment"
          paramName: 'semester_calendar[attachment]'
          error: (file, msg)->
            component.error = msg
          sending: (event, xhr, data)->
            data.append 'authenticity_token', $('meta[name=csrf-token]').attr('content')
            component.error = null
            component.status = "PDF wird hochgeladen ..."
          success: (file, response)->
            component.error = null
            component.status = null
            component.attachment = response.attachment
      }
    computed:
      card_header_title: ->
        @header || @default_card_header_title
      default_card_header_title: ->
        "Gedrucktes Programm #{@term.title}"
      uploaded_at: ->
        moment(@attachment.created_at).locale('de').format('L')

  export default SemesterCalendarAttachmentCard
</script>

<style lang="sass">
  .card.semester_calendar_pdf
    .card-body
      img
        width: 100%
    .error
      color: red
</style>