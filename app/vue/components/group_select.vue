<template>
  <div>
    <vue-select label="title" :options="options" v-model="selected" @search="fetchGroups" @input="selectedHandler" @search:blur="lostFocus" :class="multiple ? 'form-control' : 'form-select'" :placeholder="placeholder" :multiple="multiple" :filter="(list) => list">
      <template slot="selected-option" slot-scope="option">
        <div class="selected d-flex align-items-center" :title="option.corporation && (option.name + ' ' + option.corporation.name)">
          <vue-avatar :group="option" class="avatar-sm"></vue-avatar>
          {{ option.title }}
        </div>
      </template>
      <template slot="option" slot-scope="option">
        <div class="option">
          <vue-avatar :group="option" class="avatar-sm"></vue-avatar>
          {{ option.title }}
          <small class="text-muted ml-2" v-if="option.corporation && (option.corporation.id != option.id)" v-text="option.corporation.name"></small>
        </div>
      </template>
      <template #no-options="{ search, searching, loading }">
        <span v-if="loading">Passende Gruppen werden gesucht. Bitte kurz warten ...</span>
        <span v-else>Bitte Namen eingeben und Gruppe auswählen.</span>
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
    props: ['placeholder', 'value', 'multiple', 'initial_options', 'required_ability']
    data: ->
      selected: null
      options: @initial_options || []
      error: null
      current_fetch_xhr: null
    created: ->
      this.selected = this.value
    watch:
      value: ->
        this.selected = this.value
    methods:
      fetchGroups: (search, loading) ->
        component = this
        if search.length > 3
          loading true
          @current_fetch_xhr.abort() if @current_fetch_xhr
          @current_fetch_xhr = Api.get "/search_groups", {
            data:
              query: search
              required_ability: component.required_ability || 'index'
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

  .search_breadcrumb
    margin-left: 5px
    color: #999
</style>
