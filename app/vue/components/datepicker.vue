<template>
  <div>
    <vue2-datepicker
      v-model="date"
      value-type="format"
      format="DD.MM.YYYY"
      :show-week-number="true"
      :editable="false"
      input-class="form-control"
      @change="selected"
      :open.sync="open_state"
    ></vue2-datepicker>
  </div>
</template>

<script>
  import Vue from 'vue'
  import Vue2Datepicker from 'vue2-datepicker' // https://github.com/mengxiong10/vue2-datepicker
  import {de} from 'vue2-datepicker/locale/de'

  Vue.component('vue2-datepicker', Vue2Datepicker)

  export default {
    props: ['value', 'openInitially'],
    data() { return {
      date: null,
      open_state: false
    } },
    created() {
      if (this.value) {
        this.date = this.value
      }
      this.$on('open', this.open)
    },
    mounted() {
      if (this.openInitially) {
        this.open()
      }
    },
    methods: {
      open() {
        this.open_state = true
      },
      selected(val) {
        let component = this
        Vue.nextTick(() => {
          this.$emit('dateSelected', component.date)
          this.$emit('input', component.date)
        })
      },
    }
  }

</script>

<style lang="sass">
  .popup-alignment-left .vdp-datepicker__calendar
    max-width: 100%
  .popup-alignment-right .vdp-datepicker__calendar
    position: absolute
    right: 0px
  .mx-datepicker-popup
    z-index: 9000
</style>