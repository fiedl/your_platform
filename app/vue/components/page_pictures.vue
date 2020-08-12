<template lang="haml">
  %div.page_pictures
    %vue-dropzone{':options': "dropzone_options", ':useCustomSlot': "true", ':id': "'page_' + page.id + '_pictures'"}
      .text-center.mt-2.mb-4{'v-if': "editable"}
        .btn.btn-primary.upload_button Fotos hinzufügen
        .text-muted.mt-2{'v-if': "uploading == 1"} Bild wird hochgeladen ...
        .text-muted.mt-2{'v-if': "uploading > 1"} Bilder werden hochgeladen ...
        .error.text-truncate.mt-2{'v-if': "error", 'v-text': "error"}
      %vue-pictures{':attachments': "page.images", ':editable': "editable", ':show_captions': "true"}
</template>

<script lang="coffee">
  PagePictures =
    props: ['editable', 'page']
    data: ->
      component = this
      {
        error: null
        uploading: 0
        dropzone_options:
          url: "/api/v1/attachments"
          method: 'post'
          acceptedFiles: 'image/*'
          clickable: '.upload_button'
          id: "page_#{@page.id}_pictures"
          paramName: 'attachment[file]'
          createImageThumbnails: false
          error: (file, msg)->
            component.error = msg
            component.uploading -= 1
          sending: (event, xhr, data)->
            data.append 'authenticity_token', $('meta[name=csrf-token]').attr('content')
            data.append 'page_id', component.page.id
            component.error = null
            component.uploading += 1
          success: (file, new_attachment)->
            component.uploading -= 1
            component.error = null
            component.page.images.push(new_attachment)
      }

  export default PagePictures
</script>

<style lang="sass">
  .error
    color: red

</style>
