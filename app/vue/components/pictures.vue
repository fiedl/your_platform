<template lang="haml">
  .pictures
    .error.text-truncate.mb-2{'v-if': "error", 'v-text': "error"}
    .image_gallery.mt-2.row.row-sm
      %div{'v-for': "attachment in filtered_attachments", ':key': "attachment.id", ':class': "col_class"}
        .image.form-imagecheck.mb-2{':style': "aspect_ratio_style(attachment)"}
          .remove_button.btn.btn-white.btn-icon{'v-if': "editable", '@click': "remove_attachment(attachment)", title: "Bild entfernen"}
            %i.fa.fa-trash
          %img.form-imagecheck-image{':src': "attachment.file.medium.url", '@click': "activate_photoswipe_view(attachment)", ':title': "attachment.title"}
        .text-muted{'v-if': "show_captions"}
          %vue-editable{':initial-value': "attachment.title", ':editable': "editable", placeholder: "Bildunterschrift hinzufügen", ':initial-object': "attachment", ':url': "'/api/v1/attachments/' + attachment.id", paramKey: "attachment[title]"}

    / Root element of PhotoSwipe. Must have class pswp.
    .pswp{"aria-hidden": "true", role: "dialog", tabindex: "-1", 'ref': "photosweipe_element"}
      /
        Background of PhotoSwipe.
        It's a separate element as animating opacity is faster than rgba().
      .pswp__bg
      / Slides wrapper with overflow:hidden.
      .pswp__scroll-wrap
        /
          Container that holds slides.
          PhotoSwipe keeps only 3 of them in the DOM to save memory.
          Don't modify these 3 pswp__item elements, data is added later on.
        .pswp__container
          .pswp__item
          .pswp__item
          .pswp__item
        / Default (PhotoSwipeUI_Default) interface on top of sliding area. Can be changed.
        .pswp__ui.pswp__ui--hidden
          .pswp__top-bar
            / Controls are self-explanatory. Order can be changed.
            .pswp__counter
            %button.pswp__button.pswp__button--close{title: "Schließen (Esc)"}
            -//#%button.pswp__button.pswp__button--share{title: "Teilen"}
            %button.pswp__button.pswp__button--fs{title: "Vollbild"}
            %button.pswp__button.pswp__button--zoom{title: "Zoomen"}
            / Preloader demo https://codepen.io/dimsemenov/pen/yyBWoR
            / element will get class pswp__preloader--active when preloader is running
            .pswp__preloader
              .pswp__preloader__icn
                .pswp__preloader__cut
                  .pswp__preloader__donut
          .pswp__share-modal.pswp__share-modal--hidden.pswp__single-tap
            .pswp__share-tooltip
          %button.pswp__button.pswp__button--arrow--left{title: "Voriges Bild (⇽)"}
          %button.pswp__button.pswp__button--arrow--right{title: "Nächstes Bild (➝)"}
          .pswp__caption
            .pswp__caption__center
</template>

<script lang="coffee">
  # See also:
  # - https://github.com/rap2hpoutre/vue-picture-swipe/blob/master/src/VuePictureSwipe.vue
  # - https://photoswipe.com/documentation/getting-started.html

  PhotoSwipe = require('photoswipe')
  PhotoSwipeUI_Default = require('photoswipe/dist/photoswipe-ui-default')
  Api = require('../api.coffee').default

  Pictures =
    props: ['attachments', 'editable', 'show_captions']
    data: ->
      current_attachments: @attachments
      filtered_attachments: @attachments
      error: null
      search_query: null
    created: ->
      this.$root.$on 'search', @search
    methods:
      activate_photoswipe_view: (attachment)->
        pswpElement = @$refs.photosweipe_element
        options = {index: @attachments.indexOf(attachment)}
        gallery = new PhotoSwipe(pswpElement, PhotoSwipeUI_Default, @items, options)
        gallery.init()
      search: (query)->
        @search_query = query
      remove_attachment: (attachment)->
        component = this
        @current_attachments.splice(@current_attachments.indexOf(attachment), 1)
        Api.delete "/attachments/#{attachment.id}",
          error: (request, status, error)->
            component.error = request.responseText
      aspect_ratio_style: (attachment)->
        # https://www.w3schools.com/howto/howto_css_aspect_ratio.asp
        "padding-top: #{attachment.height / attachment.width * 100}%"
    computed:
      items: ->
        @filtered_attachments.map (attachment)->
          {
            src: attachment.file.url
            thumbnail: attachment.file.medium.url
            w: attachment.width
            h: attachment.height
            title: attachment.title
          }
      filtered_attachments: ->
        component = this
        @current_attachments.filter (attachment)->
          attachment.title.toLowerCase().includes(component.search_query.toLowerCase())
      col_class: ->
        if @current_attachments.length == 1
          "col-12"
        else if @current_attachments.length == 2
          "col-6"
        else
          "col-6 col-sm-4"

  export default Pictures
</script>

<style lang="sass">
  .pictures
    .image_gallery
      img.form-imagecheck-image
        opacity: 0.9
      img.form-imagecheck-image:hover
        opacity: 1.0

      .image.form-imagecheck
        position: relative
        img
          position: absolute
          top: 0
        .remove_button
          z-index: 61
          position: absolute
          left: 10px
          top: 10px

  .error
    color: red
</style>