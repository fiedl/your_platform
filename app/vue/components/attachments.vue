<template lang="haml">
  %div
    .row.mb-n3
      .col-6.row.row-sm.mb-3.align-items-center{'v-for': "attachment in attachments"}
        %a.col-auto.thumb{':href': "attachment.file_path", target: '_blank'}
          %img{':src': "attachment.file.thumb.url"}
        .col.text-truncate
          %a{':href': "attachment.file_path", target: '_blank'} {{ attachment.title }}
          .text-muted.d-block.mt-n1 {{ attachment.author_title }}
</template>

<script lang="coffee">
  Attachments =
    props: ['attachments']
  export default Attachments
</script>

<style lang="sass">
  .thumb img
    width: 3em
    border: 1px solid grey
    border-radius: 3px
</style>