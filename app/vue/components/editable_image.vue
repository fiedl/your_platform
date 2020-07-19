<template>
  <div
    @mouseover="on_hover"
    @mouseleave="on_leave"
    :class="[
      img_class,
      editable ? 'editable' : '',
      suggesting_drop ? 'suggesting_drop' : '',
      'editable_image',
      error ? 'error' : ''
    ]"
    :style="'background-image: url(' + image_url + ')'"
  >
    <vue-dropzone
      :options="dropzone_options"
      :id="attribute_name"
      :useCustomSlot="true"
      v-if="editable"
      @dragenter="suggesting_drop = true"
      @dragleave="suggesting_drop = false"
    >
      <div class="click_target">
        <a :click="edit" :class="'edit ' + edit_alignment">{{ edit_label }}</a>
      </div>
    </vue-dropzone>
  </div>
</template>

<script lang="coffee">
  `import Vue from 'vue'`
  `import VueDropzone from 'vue2-dropzone'`
  Vue.component 'vue-dropzone', VueDropzone

  EditableImage =
    props: ['src', 'editable', 'img_class', 'edit_alignment', 'update_url', 'attribute_name']
    data: ->
      self = this
      {
        image_url: null
        suggesting_edit: false
        suggesting_drop: false
        error: false
        dropzone_options:
          url: @update_url
          method: 'put'
          paramName: @attribute_name
          accepted_files: 'image/*'
          error: ->
            self.image_url = null
            alert("Der Upload hat nicht funktioniert.")
          sending: (event, xhr, data)->
            data.append 'authenticity_token', $('meta[name=csrf-token]').attr('content')
          thumbnail: (event, data)->
            self.image_url = data
        }
    created: ->
      @image_url = @src
    methods:
      on_hover: -> @suggesting_edit = true
      on_leave: -> @suggesting_edit = false
      edit: ->
        @suggesting_edit = false
    computed:
      edit_label: -> I18n.translate 'edit'

  `export default EditableImage`
</script>

<style lang="sass">
  .editable_image
    position: relative
    background-size: cover
    background-position: center
    background-repeat: none
    overflow: hidden

  .editable_image.error
    background: red

  .dz-preview
    display: none

  .click_target
    top: 0
    left: 0
    width: 100%
    height: 100%
    position: absolute

  .editable_image.editable
    cursor: grab

    a.edit
      position: absolute
      bottom: 5px
      left: 50%
      transform: translate(-50%, -50%)
      font-size: 85%
    a.top
      bottom: auto
      top: 5px
    a.right
      left: auto
      transform: none
      right: 5px

  .editable_image.editable
    -webkit-filter: brightness(100%)
    transition-property: all
    transition-duration: 0.3s

    a.edit
      opacity: 0
      transition-property: all
      transition-duration: 0.3s

  .editable_image.editable:hover
    -webkit-filter: brightness(110%)

    a.edit
      opacity: 1

  .editable_image.editable.suggesting_drop
    -webkit-filter: brightness(110%)

</style>