<template lang="haml">
  .card
    .card-body
      .row
        .col-md-6.mb-4{'v-if': "(event.contact_people && event.contact_people.length > 0) || editing"}
          %label.form-label Ansprechpartner
          %div{'v-if': "! editing"}
            .d-flex.align-items-center.mb-2{'v-for': "user in event.contact_people"}
              %a{':href': "'/users/' + user.id"}
                %vue-avatar.mr-2{':user': "user"}
              %div
                %div
                  %a.user.text-black{':href': "'/users/' + user.id"} {{ user.title }}
                %div.small
                  %a.text-muted.phone{':href': "'tel:' + user.phone", 'v-if': "user.phone"} {{ user.phone }}
          %div{'v-else': true}
            %vue-user-select{multiple: true, 'v-model': "event.contact_people", autofocus: true}
        .col-md-6{'v-if': "joinable"}
          %label.form-label
            %a.text-black{':href': "'/groups/' + attendees_group.id + '/members'"} Teilnehmer
          .avatar-list.avatar-list-stacked.d-block.mt-1.mb-1
            %a.avatar{'v-for': "user in event.attendees", ':href': "'/users/' + user.id", ':title': "user.title"}
              %vue-avatar{':user': "user"}
          .d-flex.align-items-center
            .btn.btn-primary{'v-if': "! attending", '@click': "join", key: "join"}
              %span{'v-html': "join_icon"}
              Ich bin dabei
            .btn.btn-white{'v-else': true, '@click': "leave", key: "leave"}
              %span{'v-html': "leave_icon"}
              Ich bin doch nicht dabei
            .success.ml-3{'v-if': "join_success"}
              %i.fa.fa-check
      .error.mt-3.text-danger{'v-if': "error"} {{ error.first(100) }}
    .card-footer.d-flex.align-items-center{'v-if': "editable"}
      %div{'v-if': "!editing"}
        %a.btn.btn-sm.btn-white{href: '#', '@click': "change_contact_people"} Ansprechpartner ändern
        %a.btn.btn-sm.btn-white{':href': "'/groups/' + attendees_group.id + '/members'"} Teilnehmerliste
      %div{'v-else': true}
        %a.btn.btn-primary{href: '#', '@click': "submit_contact_people"} Bestätigen
      .success.ml-3{'v-if': "contact_people_success"}
        %i.fa.fa-check
</template>

<script lang="coffee">
  Api = require('../api.coffee').default

  EventAttendees =
    props: ['initial_event', 'editable', 'joinable', 'current_user', 'join_icon', 'leave_icon', 'attendees_group']
    data: ->
      event: @initial_event
      editing: false
      join_success: false
      contact_people_success: false
      error: null
    methods:
      join: ->
        component = this
        @join_success = false
        @error = null
        @event.attendees.push(@current_user)
        Api.post "/events/#{@event.id}/join",
          success: ->
            component.join_success = true
          error: (request, status, error)->
            component.error = request.responseText
            component.event.attendees.splice(component.event.attendees.indexOf(component.current_user), 1)
      leave: ->
        component = this
        @join_success = false
        @error = null
        @event.attendees.splice(@event.attendees.indexOf(@current_user), 1)
        Api.post "/events/#{@event.id}/leave",
          success: ->
            component.join_success = true
          error: (request, status, error)->
            component.error = request.responseText
            component.event.attendees.push(component.current_user)
      change_contact_people: ->
        @join_success = false
        @contact_people_success = false
        @error = null
        @editing = true
      submit_contact_people: ->
        component = this
        @editing = false
        Api.put "/events/#{@event.id}",
          data:
            event:
              contact_people_ids: @contact_people_ids
          success: ->
            component.contact_people_success = true
          error: (request, status, error)->
            component.error = request.responseText
    computed:
      attendee_ids: ->
        @event.attendees.map (user) -> user.id
      attending: ->
        @attendee_ids.includes(@current_user.id)
      contact_people_ids: ->
        if @event.contact_people.length > 0
          @event.contact_people.map (user) -> user.id
        else
          [""] # because otherwise, jquery won't send empty arrays

  export default EventAttendees
</script>