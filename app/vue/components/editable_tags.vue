<template>
  <vue-selectize v-model="selected" :settings="settings" multiple="true" class="form-select">
    <option :value="tag.name" v-for="tag in options">{{ tag.name }}</option>
  </vue-selectize>
</template>

<script lang="coffee">
  VueSelectize = require('vue2-selectize').default
  Vue = require('vue').default

  Vue.component 'vue-selectize', VueSelectize

  EditableTags =
    props: ['initial_tags']
    data: ->
      component = this
      {
        options: []
        selected: []
        settings:
          plugins: ['remove_button'],
          placeholder: "Kategorien auswählen oder erstellen",
          inputClass: "selectize-input",
          create: true
          persist: true
          createOnBlur: true
          selectOnTab: true
          diacritics: true
          onItemAdd: (value)->
            component.selected.push value
          render:
            option_create: (data, escape)->
              "<div class='create'>Neue Kategorie: <strong>#{escape(data.input)}</strong></div>"
      }
    created: ->
      @options = @initial_tags

  export default EditableTags
</script>

<style lang="sass">
  input, input:focus
    border: 0 none
    outline: 0 none
</style>