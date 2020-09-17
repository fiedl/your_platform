<template>
  <div class="avatar" :style="style">
    <i :class="icon" v-if="! avatar_path"></i>
  </div>
</template>

<script lang="coffee">
  Avatar =
    props: ['url', 'user', 'group', 'event']
    computed:
      avatar_path: ->
        @url || (@user && @user.avatar_path) || (@group && @group.avatar_path) || (@event && @event.avatar_path)
      style: ->
        "background-image: url(#{@avatar_path})" if @avatar_path
      icon: ->
        if @group
          "fa fa-users"
        if @event
          "fa fa-calendar"

  export default Avatar
</script>