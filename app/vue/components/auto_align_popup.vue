<template>
  <div ref="wrapper" :class="alignment_class">
    <slot></slot>
  </div>
</template>

<script>
  // This is a workaround for:
  // https://github.com/charliekassel/vuejs-datepicker/issues/356#issuecomment-661152488

  import Vue from 'vue'

  export default {
    data() { return {
      alignment_class: null
    } },
    created() {
      window.addEventListener("resize", this.set_popup_alignment_class)
    },
    destroyed() {
      window.removeEventListener("resize", this.set_popup_alignment_class)
    },
    mounted() {
      Vue.nextTick(() => {
        this.set_popup_alignment_class()
      })
    },
    methods: {
      set_popup_alignment_class() {
        let relative_position = this.$refs.wrapper.getBoundingClientRect().x / window.innerWidth
        if (relative_position < 0.5) {
          this.alignment_class = "popup-alignment-left"
        } else {
          this.alignment_class = "popup-alignment-right"
        }
        this.$emit("change_alignment", this.alignment_class)
      },
    }
  }

</script>
