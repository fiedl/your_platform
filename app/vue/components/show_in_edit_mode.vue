<template>
  <div v-if="editBox().editMode">
    <slot></slot>
  </div>
</template>

<script lang="coffee">
  ShowInEditMode =
    created: ->
      this.editBox().$emit("require_edit_button")
    methods:
      editBox: ->
        this.$parent.editBox()
      editables: ->
        []
  `export default ShowInEditMode`
</script>