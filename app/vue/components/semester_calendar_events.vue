<template lang="haml">
  %div.semester_calendar_events
    %vue-edit-box{'@editMode': "on_toggle_edit_mode", ref: 'editBox'}
      .card-body
        .month.mt-2.mb-2{'v-for': "month in months"}
          %h3.month_name {{ month }}
          .table-responsive
            %table.table.table-vcenter
              %thead{'v-if': "editing"}
                %tr
                  %th.date Datum
                  %th Veranstaltung
                  %th{title: "für Philister veröffentlichen"} Philister
                  %th{title: "auf Verbindungs-Homepage veröffentlichen"} Homepage
                  %th{title: "auf Verbindungs-Homepage veröffentlichen"} wingolf.org
                  %th
              %tbody
                %tr{'v-for': "event in events_by_month(month)", ':class': "event_class(event)", ':key': "event.id"}
                  %td.date{style: 'width: 30%'}
                    .event_date
                      %vue-editable{type: 'datetime', ':initial-value': "localized_datetime(event.start_at)", ':editable': "editable", ':url': "'/events/' + event.id", 'param-key': "event[start_at]", ':render-value': "render_academic_time", '@input': "event.start_at = arguments[0].start_at"}
                  %td.event_name
                    %vue-editable{type: 'text', ':editable': "editable", ':url': "'/events/' + event.id", 'param-key': "event[name]", ':render-value': "render_event_link", ':initial-object': "event", ':initial-value': "event.name", '@input': "event.name = arguments[0].name"}
                  %td{'v-if': "editing", title: "für Philister veröffentlichen"}
                    %input.form-check-input{type: 'checkbox', 'v-model': "event.philister", '@change': "save_event(event)"}
                  %td{'v-if': "editing", title: "auf Verbindungs-Homepage veröffentlichen"}
                    %input.form-check-input{type: 'checkbox', 'v-model': "event.publish_on_local_website", '@change': "save_event(event)"}
                  %td{'v-if': "editing", title: "auf Bundes-Homepage wingolf.org veröffentlichen"}
                    %input.form-check-input{type: 'checkbox', 'v-model': "event.publish_on_global_website", '@change': "save_event(event)"}
                  %td{'v-if': "editing"}
                    %i.fa.fa-trash{'@click': "remove_event(event)", 'v-if': "editable && editing"}
      .card-footer{'v-if': "editable"}
        %a.btn.btn-white.btn-sm{'@click': "add_event"} Veranstaltung hinzufügen
</template>

<script lang="coffee">
  moment = require('moment')
  Api = require('../api.coffee').default

  SemesterCalendarEvents =
    props: ['initial_events', 'semester_calendar', 'group', 'editable', 'default_location']
    data: ->
      events: @initial_events
      editing: false
    methods:
      event_month: (event)->
        moment(event.start_at).format('MMMM YYYY')
      events_by_month: (month)->
        component = this
        @events.filter (event)->
          component.event_month(event) == month
      event_class: (event)->
        "#{if event.publish_on_global_website then 'global_event' else ''} #{if event.publish_on_local_website then 'local_event' else ''}"
      localized_datetime: (datetime)->
        moment(datetime).locale('de').format('dd, DD.MM.YYYY, H:mm')
      render_academic_time: (datetime_string)->
        datetime_string.replace(":15", "h c.t.").replace(":00", "h s.t.")
      render_event_link: (event_name, event)->
        "<a href=\"/events/#{event.id}\">#{event_name}</a>"
      add_event: ->
        latest_event = @events.sort( (event) -> event.start_at ).last()
        latest_datetime = latest_event.start_at if latest_event
        latest_datetime = moment().add(1, 'days').set('hour', 20).set('minute', 15) unless latest_datetime
        new_event = {
          id: null,
          name: "Neue Veranstaltung",
          start_at: latest_datetime,
          location: @default_location,
          aktive: true,
          philister: false
        }
        @events.push(new_event)

        Api.post '/events',
          data:
            group_id: @group.id
            event: new_event
          error: (result, message)->
            console.log(result)
          success: (event)->
            new_event.id = event.id

        this.$refs.editBox.editAll()
      remove_event: (event)->
        @events.splice(@events.indexOf(event), 1)
        Api.delete "/events/#{event.id}",
          error: (result, message)->
            console.log(result)
      on_toggle_edit_mode: (editMode)->
        @editing = editMode
      save_event: (event)->
        console.log "update"
        Api.put "/events/#{event.id}",
          data:
            event: event
    computed:
      months: ->
        component = this
        component.events.sort( (event) -> event.start_at ).map( (event) -> component.event_month(event) ).unique()

  export default SemesterCalendarEvents
</script>

<style lang="sass">
  .event_title input[type="text"]
    height: calc(1.4285714em + .875rem)

  .semester_calendar_events
    .edit-box
      margin: 0
      padding: 0

      .edit-tools
        padding-right: 20px
        padding-top: 20px

    tr.local_event .event_name
      font-size: 110%
      font-weight: bold

    tr.global_event .event_name
      font-size: 150%
      font-weight: bold

</style>