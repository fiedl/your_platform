# Make sure to run `bin/pack` after changing this file.
# Or keep `bin/webpack-dev-server` running.
# Otherwise, the changes are not picked up by the asset pipeline.

import Vue from 'vue'

import { Trash2Icon } from 'vue-feather-icons'


import VuePasswordFieldWithStrengthMeter from './VuePasswordFieldWithStrengthMeter.vue'

import VueApexCharts from 'vue-apexcharts'

import Editable from './editable.vue'
import EditableProperty from './editable_property.vue'
import EditBox from './edit_box.vue'
import ProfileField from './profile_field.vue'
import AddressProfileField from './profile_fields/address.vue'
import ProfileFields from './profile_fields.vue'
import Datepicker from './datepicker.vue'
import NumberOfMembersChart from './number_of_members_chart.vue'
import Leibfamilie from './leibfamilie.vue'
import UserSelect from './user_select.vue'
import ShowInEditMode from './show_in_edit_mode.vue'

jQuery(document).ready ->
  vue_apps = []

  Vue.component('vue-password-field-with-strength-meter', VuePasswordFieldWithStrengthMeter)
  for selector in ['#vue-change-password-app']
    vue_apps.push(new Vue({el: selector})) if jQuery(selector).count() > 0

  Vue.component('apexchart', VueApexCharts)

  Vue.component("trash-icon", Trash2Icon)

  #Vue.component('datepicker', Datepicker)
  #for selector in ['#vue-datepicker-app']
  #  vue_apps.push(new Vue({el: selector, data: {de: de, en: en}})) if jQuery(selector).count() > 0

  Vue.component('editable', Editable)
  Vue.component('vue-editable', Editable)
  Vue.component('editable-property', EditableProperty)
  Vue.component('vue-editable-property', EditableProperty)
  Vue.component('edit-box', EditBox)
  Vue.component('vue-edit-box', EditBox)
  Vue.component('profile-field', ProfileField)
  Vue.component('vue-profile-field', ProfileField)
  Vue.component('address-profile-field', AddressProfileField)
  Vue.component('vue-address-profile-field', AddressProfileField)
  Vue.component('profile-fields', ProfileFields)
  Vue.component('vue-profile-fields', ProfileFields)
  Vue.component('datepicker', Datepicker)
  Vue.component('vue-datepicker', Datepicker)
  Vue.component('number-of-members-chart', NumberOfMembersChart)
  Vue.component('vue-number-of-members-chart', NumberOfMembersChart)
  Vue.component('leibfamilie', Leibfamilie)
  Vue.component('vue-leibfamilie', Leibfamilie)
  Vue.component('user-select', UserSelect)
  Vue.component('vue-user-select', UserSelect)
  Vue.component('show-in-edit-mode', ShowInEditMode)
  Vue.component('vue-show-in-edit-mode', ShowInEditMode)

  vue_apps.push(new Vue({el: "#vue-app"}))
