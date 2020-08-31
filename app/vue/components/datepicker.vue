<template>
  <span>
    <vue2-datepicker
      v-model="date"
      value-type="format"
      :format="format"
      title-format="DD.MM.YYYY"
      time-title-format="DD.MM.YYYY"
      :type="type || 'date'"
      :show-week-number="true"
      :editable="false"
      input-class="form-control"
      :time-picker-options="time_picker_options"
      @change="selected"
      @close="closed"
      :open.sync="open_state"
    ></vue2-datepicker>
  </span>
</template>

<script>
  import Vue from 'vue'
  import Vue2Datepicker from 'vue2-datepicker' // https://github.com/mengxiong10/vue2-datepicker
  import {de} from 'vue2-datepicker/locale/de'

  Vue.component('vue2-datepicker', Vue2Datepicker)

  export default {
    props: ['value', 'openInitially', 'type'],
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
      selected(val, type) {
        let component = this
        if (((component.type == 'datetime') && (type == 'time')) || ((component.type != 'datetime') && (type == 'date'))) {
          this.$emit('dateSelected', component.date)
          this.$emit('input', component.date)
        }
      },
      closed() {
        this.$emit('closed')
      }
    },
    computed: {
      format() {
        if (this.type == "datetime") {
          return "dd, DD.MM.YYYY, H:mm"
        } else {
          return "DD.MM.YYYY"
        }
      },
      time_picker_options() {
        return {start: '6:00', end: '24:00', step: '0:15', format: 'HH:mm'}
      }
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