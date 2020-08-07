<template>
  <div>
    <div class="edit-box" v-bind:class="boxClass" v-on:click.self="saveAll">
      <div class="edit-tools" v-if="editable">
        <button class="btn btn-outline-secondary btn-sm edit-button" v-on:click.stop="toggle">{{buttonLabel}}</button>
      </div>
      <slot></slot>
    </div>
    <transition name="fade" v-if="editable">
      <div class="edit-modal-bg" v-if="editMode" v-on:click.self="saveAll"></div>
    </transition>
  </div>
</template>

<script lang="coffee">
EditBox = {
  data: -> {
    editMode: false,
    editable: false,
    partialEditing: false
  },
  created: ->
    this.$on "require_edit_button", ->
      @editable = true
  methods:
    saveAll: ->
      @editMode = false
      @.$emit 'editMode', @editMode
      @editables().forEach (c) ->
        c.waitForSave()
      @save_next_editable()
    save_next_editable: ->
      # We need to save the editables one after another
      # in order not to produce race conditions on the
      # backend.
      component = this
      next_editable = @editables().find (e)-> e.waiting_for_submission
      if next_editable
        next_editable.save
          success: -> component.save_next_editable()
          error: -> component.save_next_editable()
    editAll: ->
      @editMode = true
      @.$emit 'editMode', @editMode
      @editables().forEach (c) ->
        c.edit()
    cancelAll: ->
      @editMode = false
      @.$emit 'editMode', @editMode
      @editables().forEach (c) ->
        c.cancel()
    toggle: ->
      @editMode = !@editMode
      if @editMode == true
        @editAll()
      else
        @saveAll()
    switchOnPartialEditing: ->
      @partialEditing = true
      @editMode = true
      @editables().forEach (c) ->
        c.suggestingEdit = false
    switchOffPartialEditing: ->
      @partialEditing = false
      @editMode = false
    editBox: ->
      this
    editables: ->
      this.$children.map((child)-> (if child.editables then child.editables() else [])).flat()
  computed:
    boxClass: ->
      if @editMode
        'edit-mode'
      else
        ''
    buttonLabel: ->
      if @editMode
        I18n.translate('done')
      else
        I18n.translate('edit')
}
`export default EditBox`
</script>

<style lang="sass">
  .edit-box
    position: relative
    margin: -20px
    padding: 20px
    border-radius: 3px
    font-family: Helvetica Neue
  .edit-box.edit-mode
    z-index: 6000
    position: relative
    background: white
  .edit-tools
    float: right
    text-align: right
    .btn.btn-outline-secondary.edit-button:hover
      background: white
      color: #6e7582
  .edit-modal-bg
    position: fixed
    top: 0px
    left: 0px
    right: 0px
    bottom: 0px
    z-index: 5000
    background: black
    opacity: 0.6
  .fade-enter-active, .fade-leave-active
    transition: opacity 0.10s ease-out
  .fade-enter, .fade-leave-to
    opacity: 0
</style>