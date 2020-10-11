<template lang="haml">
  %div
    .wrapper.d-inline-block{':class': "round ? 'round' : ''", ':style': "'width: ' + (width || '5em') + '; height: ' + (height || '5em') + '; transform: rotate(' + (rotate || '36deg') + ');'"}
      .section{'v-for': "(color, index) in selected_colors", ':style': "'background-color: ' + color.hex + ';' + 'height: ' + color_section_height(index)"}
</template>

<script lang="coffee">
  Ribbon =
    props: ['value', 'round', 'width', 'height', 'rotate', 'colors']
    data: ->
      selected_colors: []
    created: ->
      @init()
    methods:
      init: ->
        @selected_colors = []
        for color_string in @value
          @selected_colors.push @colors.find((color) -> (color.name.toLowerCase() == color_string.toLowerCase()))
      color_section_height: (index)->
        if @selected_colors.length > 5 # ribbon with ground color (Konkneiptant)
          if index == 0 or index == @selected_colors.length - 1
            "4%"
          else if (index == 1 or index == @selected_colors.length - 2)
            "#{(100 - 8 * 2) / (@selected_colors.length - 3) * 0.5}%"
          else
            "#{(100 - 8 * 2) / (@selected_colors.length - 3)}%"
        else
          if index == 0 or index == @selected_colors.length - 1
            "4%"
          else
            "#{(100 - 8 * 2) / (@selected_colors.length - 2)}%"
    watch:
      value: (new_value)->
        @init()

  export default Ribbon
</script>

<style lang="sass">
  .wrapper
    overflow: hidden
  .wrapper.round
    border-radius: 50px
    border: 1px solid #ddd
  .section
    width: 100%
  .section:first-child
    margin-top: 4%
</style>