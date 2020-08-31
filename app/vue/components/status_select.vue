<template lang="haml">
  %div
    %input.form-select{':value': "status && status.name", readonly: true, 'data-toggle': "dropdown", 'data-display': "static"}
    .dropdown-menu
      %a.dropdown-item{'v-for': "s in statuses", ':style': "'padding-left: ' + ((s.level || 0) + 1) + 'rem'", '@click': "selected(s)", ':class': "(s.type == 'StatusGroup' ? '' : 'disabled') + ' ' + ((active_status_ids || []).includes(s.id) ? 'active' : '')"} {{ s.name }}
</template>

<script lang="coffee">
  StatusSelect =
    props: ['statuses', 'value', 'active_status_ids']
    data: ->
      status: @value
    methods:
      selected: (status)->
        if status.type == 'StatusGroup'
          @status = status
          @$emit('input', status)
    watch:
      value: ->
        @status = @value

  export default StatusSelect
</script>

<style lang="sass">
  .dropdown-menu
    a
      cursor: pointer
    a

</style>