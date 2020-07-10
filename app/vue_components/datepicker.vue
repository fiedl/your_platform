<template>
  <vuejs-datepicker ref="picker" :language="locale_de" :monday-first="true" format="dd.MM.yyyy" :typeable="false" :open-date="parseDate(initialDate)" :value="parseDate(initialDate)" @selected="selected" v-on-clickaway="clicked_outside"></vuejs-datepicker>
</template>

<script>
  import Vue from 'vue'
  import VuejsDatepicker from 'vuejs-datepicker' // https://github.com/charliekassel/vuejs-datepicker
  import {en, de} from 'vuejs-datepicker/dist/locale'
  import { mixin as clickaway } from 'vue-clickaway'

  Vue.component('vuejs-datepicker', VuejsDatepicker)

  export default {
    mixins: [clickaway],
    props: ['initialDate'],
    mounted() {
      this.$refs.picker.showCalendar()
    },
    methods: {
      parseDate(input) {
        var parts = input.match(/(\d+)/g);
        return new Date(parts[2], parts[1]-1, parts[0]);
      },
      selected(val) {
        Vue.nextTick(() => this.$emit('dateSelected', val))
      },
      clicked_outside() {
        // This is a workaround for https://github.com/charliekassel/vuejs-datepicker/issues/522.
        this.$refs.picker.close()
        this.$emit('cancelled')
      }
    },
    computed: {
      locale_de() {
        return de
      }
    }
  }

</script>