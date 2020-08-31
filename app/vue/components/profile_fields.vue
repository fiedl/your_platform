<template>
  <div class="profile-fields">
    <ul>
      <li v-for="profile_field in profile_fields" :key="profile_field.id">
        <vue-address-profile-field v-if="profile_field.type == 'ProfileFields::Address'" :initial-profile-field="profile_field"></vue-address-profile-field>
        <vue-profile-field :initial-profile-field="profile_field" v-else></vue-profile-field>
        <a v-on:click="remove(profile_field)" v-if="editable && editBox() && editBox().editMode" class="remove" :title="translate('remove')">
          <vue-trash-icon size="1.5x"></vue-trash-icon>
        </a>
      </li>
    </ul>
    <a v-on:click="add(new_profile_fields[0])" v-if="editable && editBox() && editBox().editMode && (new_profile_fields.length == 1)" class="btn btn-outline-secondary add">{{translate('add')}}</a>
    <div class="add" v-if="editable && editBox() && editBox().editMode && (new_profile_fields.length > 1)">
      <a class="btn btn-outline-secondary dropdown-toggle" data-toggle="dropdown">
        {{translate('add')}}
      </a>
      <div class="dropdown-menu">
        <a class="dropdown-item" v-for="new_profile_field in new_profile_fields" v-on:click="add(new_profile_field)">
          {{ new_profile_field.label }}
        </a>
      </div>
    </div>
  </div>
</template>

<script lang="coffee">

  ProfileFields = {
    data: -> {
      profile_fields: []
    }
    props: [
      'initial_profile_fields'
      'profile_field_types'
      'new_profile_fields'
      'editable'
      'profileable_id'
      'profileable_type'
    ]
    methods: {
      add: (profile_field)->
        new_profile_field = Object.assign({}, profile_field);
        new_profile_field.id = 0
        new_profile_field.editable = true
        new_profile_field.value = "" unless new_profile_field.value
        this.profile_fields.push(new_profile_field)
        $.ajax
          url: "/profile_fields",
          method: 'post',
          data:
            _method: 'post',
            profile_field: new_profile_field
            profileable_id: this.profileable_id
            profileable_type: this.profileable_type
          success: (result)->
            new_profile_field.id = result.id
            new_profile_field.children = result.children
          error: (result, message)->
            console.log(result)
      remove: (profile_field) ->
        @profile_fields.splice(@profile_fields.indexOf(profile_field), 1)
        $.ajax
          url: "/profile_fields/#{profile_field.id}",
          method: 'delete',
          error: (result, message)->
            console.log(result)
      translate: (str)->
        I18n.translate(str)
      editBox: ->
        this.$parent.editBox() if this.$parent.editBox
      editables: ->
        this.$children.map((child)-> (if child.editables then child.editables() else [])).flat()
    }
    computed: {
    }
    created: ->
      this.profile_fields = this.initial_profile_fields
      if (this.editable && this.editBox())
        this.editBox().$emit("require_edit_button")
  }
  `export default ProfileFields`
</script>

<style lang="sass">
  .profile-fields
    ul
      margin: 0
      padding: 0
    li
      list-style: none
      margin-top: .5rem
      margin-bottom: .5rem
    .profile-field
      display: inline-block
      //vertical-align: middle
    .add
      margin-top: .5rem
      margin-bottom: 2rem
</style>
