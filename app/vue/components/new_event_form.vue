<template lang="haml">
  .card.card-profile.new_event_form
    %vue-editable-image{':src': "event_avatar_background", ':editable': "false", img_class: 'card-header'}
    .card-body
      .text-center
      %vue-editable-image{':src': "event_avatar", ':editable': "false", img_class: 'card-profile-img', icon: "fa fa-group fa-2x"}

      %label.form-label.required Name der Veranstaltung
      %input.form-control{'v-model': "event.name", autofocus: true, placeholder: "Wie heißt die Veranstaltung?"}

      .row.mt-3
        .col-md-4.mb-3
          %label.form-label.required Beginn
          %vue-datepicker{'v-model': "event.start_at", type: 'datetime'}
        .col-md-4.mb-3
          %label.form-label Ende
          %vue-datepicker{'v-model': "event.end_at", type: 'datetime'}
        .col-md-4.mb-3
          %label.form-label Ort
          %input.form-control{type: 'text', 'v-model': "event.location"}

      %div
        %label.form-label.required Gruppen
        %vue-group-select{'v-model': "groups", multiple: true, ':suggested_groups': "suggested_groups"}

      .mt-3
        %label.form-label Ansprechpartner
        %vue-user-select{'v-model': "contact_people", multiple: true}

      .mt-3
        %label.form-label Beschreibung
        %vue-wysiwyg.form-control{'v-model': "event.description", placeholder: "Beschreibung, Treffpunkt, Links und weitere Informationen, ... (optional)"}

      .mt-3
        %label.form-label Veröffentlichen
        .row
          .col-md-6
            %label.form-check.form-switch
              %input.form-check-input{type: 'checkbox', 'v-model': "event.publish_on_local_website"}
              Auf Internetauftritt der Verbindung veröffentlichen
          .col-md-6
            %label.form-check.form-switch
              %input.form-check-input{type: 'checkbox', 'v-model': "event.publish_on_global_website"}
              Auf Internetauftritt des Wingolfsbundes veröffentlichen (große Veranstaltungen)
    .card-footer
      .d-flex
        %a.btn.btn-link.text-muted{'href': "/"} Abbrechen
        .ml-auto.text-right
          .form-label.error.required{'v-if': "!all_required_fields_filled_out"} Bitte alle benötigten Felder ausfüllen
          %button.btn.btn-primary{':disabled': "! submission_enabled", '@click': "submit"} Bestätigen
          .error.mt-3.text-danger{'v-if': "error"} {{ error.first(100) }}


</template>

<script lang="coffee">
  moment = require('moment')
  Api = require('../api.coffee').default

  NewEventForm =
    props: ['current_user', 'initial_groups', 'suggested_groups', 'initial_location']
    data: ->
      event:
        name: ""
        start_at: null
        end_at: null
        location: @initial_location
        publish_on_local_website: true
        publish_on_global_website: false
        description: null
      groups: @initial_groups || []
      contact_people: []
      error: null
      submitting: false
    created: ->
      @contact_people.push(@current_user) if @current_user
      @event.start_at = @localized_datetime(@tomorrow_8pm())
    methods:
      tomorrow_8pm: ->
        moment().add(1, 'days').set('hour', 20).set('minute', 15).format()
      localized_datetime: (datetime)->
        moment(datetime).locale('de').format('dd, DD.MM.YYYY, H:mm')
      submit: ->
        component = this
        @submitting = true
        Api.post "/events",
          data:
            event: @event
            contact_people_ids: @contact_people.map (user) -> user.id
            group_id: @groups[0].id
            parent_group_ids: @groups.map (group) -> group.id
          success: (new_event)->
            window.location = "/events/#{new_event.id}"
          error: (request, status, error)->
            component.error = request.responseText
            component.submitting = false
    computed:
      all_required_fields_filled_out: ->
        @event.name && @event.start_at && @groups.length > 0
      submission_enabled: ->
        @all_required_fields_filled_out && !@submitting
      event_avatar: ->
        @groups[0] && @groups[0].avatar_path
      event_avatar_background: ->
        @groups[0] && @groups[0].avatar_background_path

  export default NewEventForm
</script>

<style lang="sass">
  .new_event_form
    .mx-datepicker
      width: 100%

    .ProseMirror
      outline: 0
      min-height: 3em
      p
        margin-bottom: 0

</style>