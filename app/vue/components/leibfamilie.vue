<template>
  <div class="row">
    <div v-for="entry in leibfamilie" class="col-md-6 row row-sm align-items-center">
      <a class="col row row-sm align-items-center mb-2 obscure-in-demo" :href="'/users/' + entry.user.id">
        <span class="avatar col-auto" :style="'background-image: url(' + entry.user.avatar_path + ')'"></span>
        <div class="col">
          <div class="text-body d-block user">{{entry.user.title}}</div>
          <small class="d-block text-muted mt-n1">{{entry.description}}</small>
        </div>
      </a>
      <a v-on:click="remove(entry)" v-if="editable && entry.relationship && editBox() && editBox().editMode" class="col-auto remove" :title="translate('remove')">
        <span v-html="trash_icon"></span>
      </a>
    </div>

    <div class="add" v-if="editable && editBox() && editBox().editMode">
      <label class="form-label">Leibbursch eintragen</label>
      <vue-user-select placeholder="Leibbursch auswählen" v-on:select="leibburschSelected" :value="newLeibbursch" ref="newLeibburschSelect"></vue-user-select>

      <label class="form-label">Leibfux eintragen</label>
      <vue-user-select placeholder="Leibfuxen auswählen" v-on:select="leibfuxSelected" :value="newLeibfux" ref="newLeibfuxSelect"></vue-user-select>
    </div>
  </div>
</template>

<script lang="coffee">
  Leibfamilie = {
    props: ['initialLeibfamilie', 'user', 'editable', 'trash_icon']
    data: -> {
      leibfamilie: []
      newLeibbursch: null
      newLeibfux: null
    }
    created: ->
      this.leibfamilie = this.initialLeibfamilie
    mounted: ->
      if (this.editable && this.editBox())
        this.editBox().$emit("require_edit_button")
    methods: {
      leibburschSelected: (leibbursch)->
        component = this
        $.ajax
          url: "/api/v1/users/#{this.user.id}/leibfamilie"
          method: 'post'
          data:
            _method: 'put'
            leibbursch_id: leibbursch.id
          error: (result)->
            console.log result
          success: ->
            component.reload()
      leibfuxSelected: (leibfux)->
        component = this
        $.ajax
          url: "/api/v1/users/#{this.user.id}/leibfamilie/leibfuxen"
          method: 'post'
          data:
            _method: 'post'
            leibfux_id: leibfux.id
          error: (result)->
            console.log result
          success: ->
            component.reload()
      reload: ->
        component = this
        $.ajax
          url: "/api/v1/users/#{this.user.id}/leibfamilie"
          method: 'get'
          success: (result)->
            component.leibfamilie = result
            component.$refs.newLeibburschSelect.reset() if component.$refs.newLeibburschSelect
            component.$refs.newLeibfuxSelect.reset() if component.$refs.newLeibfuxSelect
      remove: (entry) ->
        component = this
        @leibfamilie.splice(@leibfamilie.indexOf(entry), 1)
        $.ajax
          url: "/relationships/#{entry.relationship.id}",
          method: 'delete',
          error: (result, message)->
            console.log(result)
          success: ->
            component.reload()
      translate: (str)->
        I18n.translate(str)
      editBox: ->
        this.$parent.editBox() if this.$parent.editBox
      editables: ->
        (this.$children.map (child) -> (child.editables() if child.editables) || []).flat()
    }
    computed: {}
  }
  `export default Leibfamilie`
</script>