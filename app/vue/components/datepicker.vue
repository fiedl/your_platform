<template>
  <vue-auto-align-popup>
    <vuejs-datepicker
      ref="picker"
      :language="locale_de"
      :monday-first="true"
      format="dd.MM.yyyy"
      :typeable="false"
      :open-date="date"
      :value="date"
      @selected="selected"
      @opened="opened"
      v-on-clickaway="clicked_outside"
      input-class="form-control"
    ></vuejs-datepicker>
  </vue-auto-align-popup>
</template>

<script>
  import Vue from 'vue'
  import VuejsDatepicker from 'vuejs-datepicker' // https://github.com/charliekassel/vuejs-datepicker
  import {en, de} from 'vuejs-datepicker/dist/locale'
  import { mixin as clickaway } from 'vue-clickaway'
  import moment from 'moment'

  Vue.component('vuejs-datepicker', VuejsDatepicker)

  export default {
    mixins: [clickaway],
    props: ['value', 'openInitially'],
    data() { return {
      date: null
    } },
    created() {
      moment.locale('de')
      if (this.value) {
        this.date = moment(this.value, "L").toDate()
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
        this.$refs.picker.showCalendar()
      },
      selected(val) {
        self.date = val
        let component = this
        Vue.nextTick(() => {
          this.$emit('dateSelected', self.formatted_date)
          this.$emit('input', self.formatted_date)
        })
      },
      clicked_outside() {
        // This is a workaround for https://github.com/charliekassel/vuejs-datepicker/issues/522.
        this.$refs.picker.close()
        this.$emit('cancelled')
      },
      opened() {
        // This event appears to be broken.
        // https://github.com/charliekassel/vuejs-datepicker/issues/777
      },
    },
    computed: {
      locale_de() {
        return de
      },
      formatted_date() {
        return moment(this.date).locale('de').format('L')
      }
    }
  }

</script>

<style lang="sass">
  .popup-alignment-left .vdp-datepicker__calendar
    max-width: 100%
  .popup-alignment-right .vdp-datepicker__calendar
    position: absolute;
    right: 0px;
</style>