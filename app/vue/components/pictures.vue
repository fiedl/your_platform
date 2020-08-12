<template lang="haml">
  %div
    .images.mt-2.row.row-sm
      .col-6.col-sm-4{'v-for': "attachment in attachments", ':key': "attachment.id"}
        .image.form-imagecheck.mb-2
          %img.form-imagecheck-image{':src': "attachment.file.medium.url", '@click': "activate_photoswipe_view(attachment)", ':alt': "attachment.title"}

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

  Pictures =
    props: ['attachments']
    methods:
      activate_photoswipe_view: (attachment)->
        pswpElement = @$refs.photosweipe_element
        options = {index: @attachments.indexOf(attachment)}
        gallery = new PhotoSwipe(pswpElement, PhotoSwipeUI_Default, @items, options)
        gallery.init()
    computed:
      items: ->
        @attachments.map (attachment)->
          {
            src: attachment.file.url
            thumbnail: attachment.file.medium.url
            w: attachment.width
            h: attachment.height
            title: attachment.title
          }

  export default Pictures
</script>