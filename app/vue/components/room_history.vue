<template lang="haml">
  %div
    %table.table.table-vcenter.card-table
      %thead
        %tr
          %th
          %th Bewohner
          %th Von
          %th Bis
          %th.w-1{'v-if': "editable"} Entfernen
      %tbody
        %tr{'v-for': "occupancy in occupancies"}
          %td.w-1
            %vue-avatar{':url': "occupancy.occupant.avatar_path", 'v-if': "occupancy.occupant"}
          %td
            %a{'v-if': "occupancy.occupant", ':href': "'/users/' + occupancy.occupant.id"} {{ occupancy.occupant.title }}
            .text-muted{'v-else': true, 'v-text': "occupancy.occupant_title || 'Ausgeblendete Person'"}
          %td
            %vue-editable{':initial-value': "format_date(occupancy.valid_from)", ':url': "'/memberships/' + occupancy.id", paramKey: "membership[valid_from]", ':editable': "editable", type: 'date'}
          %td
            %vue-editable{':initial-value': "format_date(occupancy.valid_to)", ':url': "'/memberships/' + occupancy.id", paramKey: "membership[valid_to]", ':editable': "editable", type: 'date'}
          %td{'v-if': "editable"}
            %a.remove{'@click': "remove(occupancy)"}
              %i.fa.fa-trash

</template>

<script lang="coffee">
  Vue = require 'vue'
  Api = require '../api.coffee'
  moment = require 'moment'

  RoomHistory =
    props: ['room', 'initial_occupancies', 'editable']
    data: ->
      occupancies: []
    created: ->
      @occupancies = @initial_occupancies
    methods:
      remove: (occupancy) ->
        @occupancies.splice(@occupancies.indexOf(occupancy), 1)
        $.ajax
          url: "/memberships/#{occupancy.id}",
          method: 'delete',
          error: (result, message)-> alert "Das Löschen hat nicht funktioniert: #{message}"
      format_date: (date)->
        moment(date).locale('de').format('L') if date
      editables: ->
        this.$children.map((child)-> (if child.editables then child.editables() else [])).flat()
      editBox: ->
        this.$parent.editBox()

  export default RoomHistory
</script>