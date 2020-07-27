<template>
  <div>
    <textarea
      v-if="type == 'textarea'"
      v-model.trim="value"
      autofocus
    ></textarea>
    <vue-datepicker
      v-else-if="type == 'date'"
      v-model="value"
      v-on:dateSelected="save"
      :placeholder="placeholder"
    ></vue-datepicker>
    <input
      v-else
      :type="type || 'text'"
      v-model.trim="value"
      v-on:keyup.enter="save"
      v-on:blur="save"
      v-autowidth="{maxWidth: '960px', minWidth: '50px', comfortZone: 0}"
      :placeholder="placeholder"
      autofocus
    />
  </div>
</template>

<script lang="coffee">
  Vue = require('vue').default

  EditableSetting =
    props: ['type', 'setting', 'placeholder']
    data: ->
      value: null
    created: ->
      @value = @setting.value
    methods:
      save: ->
        self = this
        Vue.nextTick ->
          $.ajax
            url: "/settings/#{self.setting.id}"
            method: 'post'
            data:
              _method: 'put'
              value: self.value
            error: -> console.log("error")

  export default EditableSetting
</script>

