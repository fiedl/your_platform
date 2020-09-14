<template>
  <div>
    <vue-select ref="vue_select" label="title" :options="options" v-model="selected" @search="fetchUsers" @input="selectedHandler" @search:blur="lostFocus" :class="multiple ? 'form-control' : 'form-select'" :placeholder="placeholder" :multiple="multiple" :filterable="false">
      <template slot="option" slot-scope="option">
        <div class="option">
          <span class="avatar avatar-sm rounded mr-2 ml-n1" :style="'background-image: url(' + option.avatar_path + ')'"></span>
          {{ option.title }}
          <small class="ml-3">{{ option.search_hint }}</small>
        </div>
      </template>
      <template slot="selected-option" slot-scope="option">
        <div class="selected d-flex align-items-center">
          <span class="avatar avatar-sm rounded mr-2 ml-n1" :style="'background-image: url(' + option.avatar_path + ')'"></span>
          {{ option.title }}
        </div>
      </template>
      <template #no-options="{ search, searching, loading }">
        <span v-if="loading">Passende Personen werden gesucht. Bitte kurz warten ...</span>
        <span v-else>Bitte Namen eingeben und Person auswählen.</span>
      </template>
    </vue-select>
    <div class="error" v-if="error" v-text="error.first(100)"></div>
  </div>
</template>

<script lang="coffee">
  Api = require('../api.coffee').default
  Vue = require('vue').default
  VueSelect = require('vue-select').default # https://github.com/sagalbot/vue-select

  Vue.component 'vue-select', VueSelect

  UserSelect =
    props: ['placeholder', 'value', 'find_non_wingolf_users', 'find_deceased_users', 'multiple', 'initial_options', 'autofocus']
    data: ->
      selected: null
      options: @initial_options || []
      error: null
      current_fetch_xhr: null
    created: ->
      this.selected = this.value
    mounted: ->
      # this.$refs.vue_select.focus() if @autofocus # FIXME
    watch:
      value: ->
        this.selected = this.value
    methods:
      fetchUsers: (search, loading) ->
        component = this
        if search.length > 3
          loading true
          @current_fetch_xhr.abort() if @current_fetch_xhr
          @current_fetch_xhr = Api.get "/search_users", {
            data:
              query: search
              find_non_wingolf_users: component.find_non_wingolf_isers
              find_deceased_users: component.find_deceased_users
            success: (result)->
              component.options = result
              loading false
            error: (request, status, error)->
              component.error = request.responseText
              loading false
          }
        else
          component.options = @initial_options || []
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
    .vs__open-indicator
      display: none
  .vs__selected-options
    padding-top: 4px
    padding-left: 3px
  .vs__search
</style>
