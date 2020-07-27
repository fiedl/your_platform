<template lang="haml">
  %div
    .row.row-deck
      .col-md-6{'v-for': "room in rooms", ':key': "room.id"}
        .card.card-profile
          %vue-editable-image{':src': "room.customized_avatar_background_path", edit_alignment: "top right", ':editable': "editable && room.id > 0", img_class: 'card-header', ':update_url': "'/groups/' + room.id", attribute_name: "group[avatar_background]", ':icon': "room.occupant ? null : 'fa fa-home fa-2x'"}
          .card-body.text-center
            %vue-edit-box
              %vue-editable-image{':src': "room.occupant.avatar_path", img_class: "card-profile-img", ':editable': "editable", ':update_url': "'/users/' + room.occupant.id", attribute_name: 'user[avatar]', 'v-if': "room.occupant"}
              %h3.mb-3.clear
                %vue-editable{ref: "room_name", ':data-room-id': "room.id", ':initial-value': "room.name", ':url': "'/groups/' + room.id", paramKey: "group[name]", ':editable': "editable", type: 'text'}
              %a.occupant{':href': "'/users/' + room.occupant.id", 'v-if': "room.occupant"} {{ room.occupant.title }}
              .occupant_since{'v-if': "room.occupant_since"}
                Bewohner seit: {{ format_date(room.occupant_since) }}
              .rent
                Miete:
                %vue-editable{':initial-value': "room.rent", ':url': "'/api/v1/corporations/' + corporation.id + '/rooms/' + room.id", paramKey: "room[rent]", ':editable': "editable", type: 'number'}
                €
          .card-footer{'v-if': "room.id > 0"}
            %a.btn.btn-white.btn-sm{'v-if': "room.previous_and_current_occupants_count && room.previous_and_current_occupants_count > 0", ':href': "'/groups/' + room.id + '/room_occupancies'"} Historie
            %a.btn.btn-white.btn-sm{'v-if': "editable", ':href': "'/groups/' + room.id + '/room_occupancies/new'"} Bewohner ändern
            %a.btn.btn-danger.btn-sm{'v-if': "editable && room.previous_and_current_occupants_count == 0", '@click': "remove_room(room)"} Zimmer entfernen
    .mt-3.text-center.mb-5{'v-if': "editable"}
      .btn.btn-secondary{'@click': "add_room"} Zimmer hinzufügen
</template>

<script lang="coffee">
  Vue = require('vue').default
  Api = require('../api.coffee').default
  moment = require 'moment'

  Rooms =
    props: ['initial_rooms', 'corporation', 'editable']
    data: ->
      rooms: []
    created: ->
      @rooms = @initial_rooms
    methods:
      add_room: ->
        self = this
        new_room = {}
        new_room.id = 0
        new_room.rent = 100
        new_room.name = "Neues Zimmer"
        @rooms.push new_room
        Api.post "/corporations/#{@corporation.id}/rooms", {
          data:
            room: new_room
          success: (room)->
            new_room.id = room.id
            new_room.previous_and_current_occupants_count = 0
            Vue.nextTick ->
              self.$refs.room_name.each (editable)->
                if editable.value == "Neues Zimmer"
                  editable.edit()
        }
      remove_room: (room)->
        @rooms.splice(@rooms.indexOf(room), 1)
        Api.delete "/corporations/#{@corporation.id}/rooms/#{room.id}", {}
      format_date: (date)->
        moment(date).locale('de').format('L')

  `export default Rooms`
</script>
