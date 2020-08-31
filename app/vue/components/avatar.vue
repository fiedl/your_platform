<template>
  <div class="avatar" :style="style">
    <i :class="icon" v-if="! avatar_path"></i>
  </div>
</template>

<script lang="coffee">
  Avatar =
    props: ['url', 'user', 'group']
    computed:
      avatar_path: ->
        @url || (@user && @user.avatar_path) || (@group && @group.avatar_path)
      style: ->
        "background-image: url(#{@avatar_path})" if @avatar_path
      icon: ->
        if @group
          "fa fa-users"

  export default Avatar
</script>