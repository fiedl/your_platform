<template lang="haml">
  %div
    .wrapper.d-inline-block{':class': "selecting_color_index ? 'selecting' : ''"}
      .section{'v-for': "(color, index) in selected_colors", ':style': "'background-color: ' + color.hex", '@click': "selecting_color_index = index", ':class': "index == selecting_color_index ? 'active' : ''"}
    .dropdown-menu.color-pallette.d-inline-block.show{'v-if': "selecting_color_index && selecting_color_index > 0"}
      %li.dropdown-item{'v-for': "color in colors", '@click': "select(color)", ':class': "color.name == selected_colors[selecting_color_index].name ? 'active' : ''"}
        .color-circle.mr-2{':style': "'background-color: ' + color.hex"}
        %span {{ color.name }}

</template>

<script lang="coffee">
  EditableRibbon =
    props: ['value', 'editable']
    data: ->
      selected_colors: []
      selecting_color_index: null
      colors: [
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
      ]
    methods:
      select: (color)->
        @selected_colors[@selecting_color_index] = color
        @selecting_color_index = null
    created: ->
      for color_string in @value
        @selected_colors.push @colors.find((color) -> color.name == color_string)

  export default EditableRibbon
</script>

<style lang="sass">
  .wrapper
    border-radius: 50px
    overflow: hidden
    width: 5em
    height: 5em
    transform: rotate(36deg)
  .section
    height: 27%
    width: 100%
  .section:first-child
    height: 10%
  .section:last-child
    height: 10%
  .selecting
    .section
      opacity: 0.2
    .section.active
      opacity: 1


  .color-circle
    width: 1em
    height: 1em
    border-radius: 1em
    border: 1px solid lightgrey
  .dropdown-menu.color-pallette
    left: auto
    top: auto
</style>