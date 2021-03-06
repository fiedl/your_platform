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
    <div class="icon_container" v-if="(! image_url) && icon">
      <i :class="icon"></i>
    </div>

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

    <div :class="'download ' + download_alignment" v-if="download_url || src">
      <a :href="download_url || src" target="_blank" title="Bild herunterladen"><span v-html="download_icon"></span></a>
    </div>
  </div>
</template>

<script lang="coffee">
  Vue = require('vue').default
  VueDropzone = require('vue2-dropzone')

  Vue.component 'vue-dropzone', VueDropzone

  EditableImage =
    props: ['src', 'editable', 'img_class', 'tools_alignment', 'update_url', 'attribute_name', 'icon', 'download_icon', 'link_to', 'download_url']
    data: ->
      component = this
      {
        image_url: null
        suggesting_edit: false
        suggesting_drop: false
        error: false
        dropzone_options:
          url: @update_url
          method: 'put'
          paramName: @attribute_name
          acceptedFiles: 'image/*'
          maxFilesize: 7 # MB
          error: (file, msg)->
            component.image_url = null
            alert("Der Upload hat nicht funktioniert: " + msg)
          sending: (event, xhr, data)->
            data.append 'authenticity_token', $('meta[name=csrf-token]').attr('content')
          thumbnail: (event, data)->
            component.image_url = data
          success: (file, response)->
            component.image_url = file.dataURL
        }
    created: ->
      @image_url = @src
    methods:
      on_hover: -> @suggesting_edit = true
      on_leave: -> @suggesting_edit = false
      edit: ->
        @suggesting_edit = false
      editables: -> []
    computed:
      edit_label: -> "Bild ändern"
      edit_alignment: ->
        if @tools_alignment == 'center'
          'center'
        else
          'top right'
      download_alignment: ->
        if @tools_alignment == 'center'
          'bottom center'
        else
          'bottom right'
    watch:
      src: (new_source)->
        @image_url = new_source

  export default EditableImage
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

  .click_target, .icon_container
    top: 0
    left: 0
    width: 100%
    height: 100%
    position: absolute

  .icon_container
    display: flex
    align-items: center
    justify-content: center
    background-color: #eee
    .fa-2x
      font-size: 2em !important

  .editable_image.editable
    cursor: pointer

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

  .download
    position: absolute
  .download.right
    right: 5px
  .download.center
    left: 50%
    transform: translate(-50%, -50%)
  .download.bottom
    bottom: 5px

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


  .editable_image
    .download a
      opacity: 0
      transition-property: all
      transition-duration: 0.3s

  .editable_image:hover
    .download a
      opacity: 1


</style>