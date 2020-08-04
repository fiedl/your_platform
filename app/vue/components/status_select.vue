<template lang="haml">
  %div
    %input.form-select{':value': "status && status.name", readonly: true, 'data-toggle': "dropdown", 'data-display': "static"}
    .dropdown-menu
      %a.dropdown-item{'v-for': "s in statuses", ':style': "'margin-left: ' + s.level + 'rem'", '@click': "selected(s)"} {{ s.name }}
</template>

<script lang="coffee">
  StatusSelect =
    props: ['statuses', 'value']
    data: ->
      status: @value
    methods:
      selected: (status)->
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
</style>