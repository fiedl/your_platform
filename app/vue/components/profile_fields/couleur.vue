<template lang="haml">
  %div
    .ribbon_section.mt-3.mb-2
      %vue-editable-ribbon{':value': "apparent_colors"}
    %div
      %label.form-label Farben
      %vue-heraldic-color-select{'v-model': "profile_field.colors[0]", '@input': "update"}
      %vue-heraldic-color-select{'v-model': "profile_field.colors[1]", '@input': "update"}
      %vue-heraldic-color-select{'v-model': "profile_field.colors[2]", '@input': "update"}

      %label.form-label.mt-4 Auf Grundfarbe
      %vue-heraldic-color-select{'v-model': "profile_field.ground_color", '@input': "update"}

      %label.form-label.mt-4 Perkussion
      %vue-heraldic-color-select{'v-model': "profile_field.percussion_colors[0]", '@input': "update"}
      %vue-heraldic-color-select{'v-model': "profile_field.percussion_colors[1]", '@input': "update"}

      %label.form-check.form-switch.mt-4
        %input.form-check-input{type: 'checkbox', 'v-model': "profile_field.reverse", '@input': "update"}
        %span.form-check-label Von unten getragen
</template>

<script lang="coffee">
  Api = require('../../api.coffee').default
  Vue = require('vue').default

  CouleurProfileField =
    props: ['initial_profile_field', 'editable']
    data: ->
      profile_field: @initial_profile_field
    methods:
      update: ->
        component = this
        setTimeout ->
          Api.put "/profile_fields/couleur/#{component.profile_field.id}",
            data:
              profile_field: component.profile_field
        , 200 # to give the @profile_field time to update
    computed:
      apparent_colors: ->
        array = []
        for color in @profile_field.colors
          array.push color if color
        if @profile_field.ground_color
          array.unshift @profile_field.ground_color
          array.push @profile_field.ground_color
        if @profile_field.percussion_colors[0]
          array.unshift @profile_field.percussion_colors[0]
        if @profile_field.percussion_colors[1]
          array.push @profile_field.percussion_colors[1]
        array = array.reverse() if @profile_field.reverse
        array

  export default CouleurProfileField
</script>

<style lang="sass">
  .ribbon_section
    text-align: center
</style>