<template>
  <div class="avatar" :style="style">
  </div>
</template>

<script lang="coffee">
  Avatar =
    props: ['url', 'user', 'group']
    computed:
      avatar_path: ->
        @url || @user.avatar_path || @group.avatar_path
      style: ->
        "background-image: url(#{@avatar_path})"

  export default Avatar
</script>