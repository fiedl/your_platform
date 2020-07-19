<template>
  <vue-select label="title" :options="options" v-model="selected" @search="fetchUsers" @input="selectedHandler" @search:blur="lostFocus" class="form-select" :placeholder="placeholder">
    <template slot="option" slot-scope="option">
      <div class="option">
        <span class="avatar avatar-sm rounded mr-2 ml-n1" :style="'background-image: url(' + option.avatar_url + ')'"></span>
        {{ option.title }}
      </div>
    </template>
    <template slot="selected-option" slot-scope="option">
      <div class="selected d-flex align-items-center">
        <span class="avatar avatar-sm rounded mr-2 ml-n1" :style="'background-image: url(' + option.avatar_url + ')'"></span>
        {{ option.title }}
      </div>
    </template>
    <template #no-options="{ search, searching, loading }">
      Bitte Namen eingeben und Person auswählen.
    </template>
  </vue-select>
</template>

<script lang="coffee">
  `import Vue from 'vue'`
  `import VueSelect from 'vue-select'` # https://github.com/sagalbot/vue-select

  Vue.component 'vue-select', VueSelect

  UserSelect =
    props: ['placeholder', 'value']
    data: ->
      selected: null
      options: []
    methods:
      fetchUsers: (search, loading) ->
        self = this
        if search.length > 3
          loading true
          $.ajax
            method: 'get'
            url: "/api/v1/search_users?query=#{search}"
            success: (result)->
              self.options = result
              loading false
            error: (result)->
              console.log result
        else
          self.options = []
      lostFocus: ->
        this.$emit('lostFocus')
      selectedHandler: (v)->
        self = this
        Vue.nextTick ->
          self.$emit('select', self.selected)
          self.$emit('input', self.selected)
      reset: ->
        this.selected = null
  `export default UserSelect`
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
