<template>
  <vue-select label="title" :options="options" v-model="selected" @search="fetchUsers" @input="selectedHandler" @search:blur="lostFocus" class="form-select" :placeholder="placeholder">
    <template slot="option" slot-scope="option">
      <div class="option">
        <span class="avatar avatar-sm rounded mr-2 ml-n1" :style="'background-image: url(' + option.avatar_path + ')'"></span>
        {{ option.title }}
      </div>
    </template>
    <template slot="selected-option" slot-scope="option">
      <div class="selected d-flex align-items-center">
        <span class="avatar avatar-sm rounded mr-2 ml-n1" :style="'background-image: url(' + option.avatar_path + ')'"></span>
        {{ option.title }}
      </div>
    </template>
    <template #no-options="{ search, searching, loading }">
      Bitte Namen eingeben und Person auswählen.
    </template>
  </vue-select>
</template>

<script lang="coffee">
  Api = require('../api.coffee').default
  Vue = require('vue').default
  VueSelect = require('vue-select').default # https://github.com/sagalbot/vue-select

  Vue.component 'vue-select', VueSelect

  UserSelect =
    props: ['placeholder', 'value', 'find_non_wingolf_users', 'find_deceased_users']
    data: ->
      selected: null
      options: []
    created: ->
      this.selected = this.value
    watch:
      value: ->
        this.selected = this.value
    methods:
      fetchUsers: (search, loading) ->
        component = this
        if search.length > 3
          loading true
          Api.get "/search_users", {
            data:
              query: search
              find_non_wingolf_users: component.find_non_wingolf_isers
              find_deceased_users: component.find_deceased_users
            success: (result)->
              component.options = result
              loading false
            error: (result)->
              console.log result
          }
        else
          component.options = []
      lostFocus: ->
        this.$emit('lostFocus')
      selectedHandler: (v)->
        component = this
        Vue.nextTick ->
          component.$emit('select', component.selected)
          component.$emit('input', component.selected)
      reset: ->
        this.selected = null

  export default UserSelect
</script>

<style lang="sass">
  .vs--searchable
    margin: 0
    padding: 0
  .vs__dropdown-toggle
    margin: 0
    border: none
  .vs__actions
    display: none
  .vs__selected-options
    padding-top: 4px
    padding-left: 3px
  .vs__search
</style>
