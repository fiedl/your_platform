<template lang="haml">
  %div
    #current_user_global_couleur_ribbons{'v-show': "show_ribbon"}
      .ribbon_rotate
        .mb-2{'v-for': "ribbon in current_user_ribbons", key: "ribbon.id"}
          %vue-ribbon{':value': "ribbon.apparent_colors", height: "60px", width: "100%", rotate: '0deg', ':colors': "color_palette"}
    .container-xl{'v-if': "current_user"}
      .right
        .view_menu_trigger.dropdown-toggle{'data-toggle': "dropdown"} Ansicht
        .dropdown-menu.dropdown-menu-right
          .pr-3.pl-3
            %label.form-check.form-switch
              %input.form-check-input{type: 'checkbox', 'v-model': "show_ribbon", '@change': "update_show_ribbon_setting"}
              %span.form-check-label
                %span{'v-if': "current_user_ribbons.length == 1"} Band anzeigen
                %span{'v-else': true} Bänder anzeigen
            .mt-2
              %label.form-check.form-check-inline
                %input.form-check-input{type: 'radio', name: 'theme', value: "dark", '@change': "activate_dark_mode", 'v-model': "dark_mode"}
                %span.form-check-label Dark
              %label.form-check.form-check-inline
                %input.form-check-input{type: 'radio', name: 'theme', value: "light", '@change': "activate_light_mode", 'v-model': "dark_mode"}
                %span.form-check-label Light
              %label.form-check.form-check-inline
                %input.form-check-input{type: 'radio', name: 'theme', value: "auto", '@change': "activate_auto_dark_mode", 'v-model': "dark_mode"}
                %span.form-check-label Auto
</template>

<script lang="coffee">
  Api = require('../api.coffee').default
  Vue = require('vue').default

  RightCornerRibbon =
    props: ['current_user', 'initial_dark_mode', 'initial_show_ribbon', 'color_palette', 'current_user_ribbons']
    data: ->
      dark_mode: @initial_dark_mode
      show_ribbon: @initial_show_ribbon
    methods:
      activate_dark_mode: ->
        @dark_mode = "dark"
        App.deactivate_auto_dark_mode()
        App.activate_dark_mode()
        @update_setting 'dark_mode', "dark"
      activate_light_mode: ->
        @dark_mode = "light"
        App.deactivate_auto_dark_mode()
        App.deactivate_dark_mode()
        @update_setting 'dark_mode', "light"
      activate_auto_dark_mode: ->
        @dark_mode = "auto"
        App.activate_auto_dark_mode()
        @update_setting 'dark_mode', "auto"
      update_show_ribbon_setting: ->
        @update_setting "show_ribbon", @show_ribbon
      update_setting: (key, value)->
        Api.put "/users/#{@current_user.id}/settings/#{key}",
          data:
            value: value
          error: ->
            alert("Einstellung '#{key}' konnte nicht gespeichert werden.")

  export default RightCornerRibbon
</script>

<style lang="sass">
  .view_menu_trigger
    opacity: 0.3
    cursor: pointer
  .view_menu_trigger:hover, .view_menu_trigger:active
    opacity: 1.0
</style>