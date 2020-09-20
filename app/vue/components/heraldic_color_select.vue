<template lang="haml">
  %div
    %a.form-select.d-flex.align-items-center{'data-toggle': 'dropdown'}
      .color-circle.mr-2{':style': "'background-color: ' + selected.hex", 'v-if': "selected.hex"}
      %span {{ selected.name }}
    .dropdown-menu
      %li.dropdown-item{'v-for': "color in current_colors", '@click': "on_select(color)"}
        .color-circle.mr-2{':style': "'background-color: ' + color.hex", 'v-if': "color.hex"}
        %span {{ color.name }}
</template>

<script lang="coffee">
  HeraldicColorSelect =
    props: ['value', 'colors']
    data: ->
      selected: null
      current_colors: @colors || [
        {name: "Schwarz", hex: "#000000"},
        {name: "Weiß", hex: "#ffffff"},
        {name: "Gold", hex: "#f6bc5c"},
        {name: "Altgold", hex: "#d58b0a"},
        {name: "Silber", hex: "#7f7f7f"},
        {name: "Rot", hex: "#fe0000"},
        {name: "Dunkelrot", hex: "#7f0000"},
        {name: "Blau", hex: "#1100bd"},
        {name: "Hellblau", hex: "#62b0fe"}
        {name: "Lila", hex: "#b960e5"},
        {name: "Grün", hex: "#008700"},
        {name: "Keine", hex: null},
      ]
    methods:
      on_select: (color)->
        @selected = color
        if color.hex
          @$emit 'input', color.name
        else
          @$emit 'input', null
    created: ->
      component = this
      @selected = @current_colors.find((color) -> color.name.toLowerCase() == component.value.toLowerCase()) if component.value
      @selected ||= @current_colors[@current_colors.length - 1]
  export default HeraldicColorSelect
</script>

<style lang="sass">
  .color-circle
    width: 1em
    height: 1em
    border-radius: 1em
    border: 1px solid lightgrey

</style>