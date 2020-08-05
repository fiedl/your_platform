<template>
  <span v-on:mouseenter="suggestEdit">
    <transition name="fade" mode="out-in">

      <span key="3" class='read' v-on:click="edit_if_not_a_link" v-if="!showEditField">
        <span class="value" v-html="rendered_value()"></span>
        <span v-if="submitting" class="submitting">•••</span>
        <span v-if="success" class="success">✔</span>
        <span v-if="error" class="error-icon">✘</span>
      </span>

      <span key="1" class='edit' v-bind:class="editingClass" v-if="showEditField" v-on:click="acceptEditSuggestion" v-on:keydown.esc="cancelAll">
        <textarea v-if="typeIsTextarea" v-on:keydown="keydownToBeginEditing" v-model.trim="value" :placeholder="placeholder" autofocus :class="input_class"></textarea>
        <vue-datepicker :open-initially="editing && !(editBox() && editBox().editMode && !editBox().partialEditing)" v-else-if="type == 'date'" v-model="value" v-on:dateSelected="dateSelected" @closed="focusLost"></vue-datepicker>
        <input v-else :type="type || 'text'" v-model.trim="value" v-on:keydown="keydownToBeginEditing" v-on:keyup.enter="saveAll"  v-on:blur="focusLost()" v-autowidth="{maxWidth: '960px', minWidth: '50px', comfortZone: 0}" :placeholder="placeholder" autofocus :class="input_class" />
        <div class="error-message" v-if="error">{{error}}</div>
        <div class="help" v-if="help">{{help}}</div>
      </span>

    </transition>
  </span>
</template>

<script>
  import Vue from 'vue'

  import VueInputAutowidth from 'vue-input-autowidth'
  Vue.use(VueInputAutowidth)

  export default {
    props: ['initialValue', 'type', 'help', 'url', 'paramKey', 'renderValue', 'editable', 'placeholder', 'input_class'],
    data() { return {
      editing: false,
      suggestingEdit: false,
      value: null,
      valueBeforeEdit: null,
      success: false,
      submitting: false,
      waiting_for_submission: false,
      error: null
    } },
    created() {
      if (this.initialValue) {
        this.value = this.initialValue
      }
      if (this.editBox() && this.editBox().editMode) {
        this.edit()
      }
      if (this.editable && this.editBox()) {
        this.editBox().$emit("require_edit_button")
      }
    },
    methods: {
      rendered_value() {
        if (this.renderValue) {
          return this.renderValue(this.value)
        } else {
          return this.value
        }
      },
      edit_if_not_a_link() {
        if (this.rendered_value() && this.rendered_value().includes("<a ")) {
          return
        } else {
          this.edit()
        }
      },
      edit() {
        let component = this
        if (this.editable && (! this.editing)) {
          this.$emit('edit')
          this.valueBeforeEdit = this.value
          this.editing = true
          this.success = false
          if (this.editBox() && !this.editBox().editMode) {
            this.editBox().switchOnPartialEditing()
          }
        }
      },
      acceptEditSuggestion() {
        if (this.suggestingEdit) {
          this.edit()
        }
      },
      focus() {
        if (this.inputField) {
          let component = this
          Vue.nextTick(function() { component.inputField.focus() })
        }
      },
      focusLost() {
        if (! this.editBox()) {
          this.save()
        }
      },
      dateSelected(val) {
        this.value = val
        if ((! this.editBox()) || (this.editBox().partialEditing)) {
          this.save()
        }
      },
      waitForSave() {
        this.suggestingEdit = false
        if (this.editing) {
          this.editing = false
          this.waiting_for_submission = true
        }
      },
      save(options = {}) {
        this.suggestingEdit = false
        if (this.editing || this.waiting_for_submission) {
          this.editing = false
          this.waiting_for_submission = false
          if (this.editBox()) {
            this.editBox().switchOffPartialEditing()
          }
          if (this.value != this.valueBeforeEdit) {
            this.submitSave(options)
          } else {
            if (options.success) { options.success() }
            if (options.complete) { options.complete() }
          }
        }
      },
      saveAll() {
        if (this.editBox()) {
          this.editBox().saveAll()
        } else {
          this.save()
        }
        return false // stop event propagation
      },
      cancelAll() {
        if (this.editBox()) {
          this.editBox().cancelAll()
        } else {
          this.cancel()
        }
      },
      suggestEdit() {
        if (! (this.editBox() && this.editBox().editMode)) {
          this.suggestingEdit = true
          this.cancelSuggestEditWithDelay()
        }
      },
      cancel() {
        if (this.editing) {
          this.value = this.valueBeforeEdit
          this.editing = false
          this.error = false
        }
        this.suggestingEdit = false
      },
      cancelSuggestEdit() {
        this.suggestingEdit = false
      },
      cancelSuggestEditWithDelay() {
        setTimeout(this.cancelSuggestEdit, 1500)
      },
      submitSave(options = {}) {
        let component = this
        this.submitting = true
        $.ajax({
          url: this.url,
          method: 'post',
          data: {
            _method: 'put',
            [this.paramKey]: this.value
          },
          success: function(result) {
            component.submitting = false
            component.success = true
            component.error = false
            if (options.success) { options.success() }
          },
          error: function(result, message) {
            component.submitting = false
            component.success = false
            component.error = message
            var oldValue = component.valueBeforeEdit
            component.edit()
            component.valueBeforeEdit = oldValue // because edit() replaces this value
            component.editing = true
            if (options.error) { options.error() }
          },
        })
      },
      keydownToBeginEditing(event) {
        if (event.keyCode != 27) { this.edit() }
      },
      editBox() {
        if (this.$parent.editBox) {
          return this.$parent.editBox()
        }
      },
      editables() {
        return [this]
      },
    },
    computed: {
      showEditField() {
        //return (this.editing || this.suggestingEdit)
        return this.editing
      },
      typeIsTextarea() {
        return (this.type == "textarea")
      },
      editingClass() {
        if (this.error) { return "error" }
        if (this.suggestingEdit && !this.editing) { return "suggesting" } else { return "" }
      },
      inputField() {
        return this.$el.getElementsByTagName("input")[0] || this.$el.getElementsByTagName("textarea")[0]
      }
    }
  }
</script>

<style lang="sass">
  .read .value
    white-space: pre-line
  textarea
    white-space: pre-line
  input, select, textarea
    border: none
    padding: 0
    margin: 0
    font: inherit
    color: inherit
    line-height: inherit
    font-size: inherit
    text-align: inherit
    vertical-align: top
  .success
    color: green
  .submitting
    color: yellow
  .error-icon
    color: red
  .help, .error-message
    margin-top: 5px
    margin-bottom: 10px
    font-size: 90%
    max-width: 90%
  .error-message
    color: red
    font-size: 11pt
  .edit
    input, textarea
      background: rgba(0,0,0, 0.1)
  .suggesting.edit
    input, textarea
      background: rgba(0,0,0, 0.05)
  .edit.error
    input, textarea
      background: rgba(255,0,0, 0.6)
</style>