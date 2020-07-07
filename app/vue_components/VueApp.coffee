# Make sure to run `bin/pack` after changing this file.
# Or keep `bin/webpack-dev-server` running.
# Otherwise, the changes are not picked up by the asset pipeline.

import Vue from 'vue'
import TurbolinksAdapter from 'vue-turbolinks' # https://github.com/jeffreyguenther/vue-turbolinks

import { Trash2Icon } from 'vue-feather-icons'


import VuePasswordFieldWithStrengthMeter from './VuePasswordFieldWithStrengthMeter.vue'


import Editable from './editable.vue'
import EditableProperty from './editable_property.vue'
import EditBox from './edit_box.vue'
import ProfileField from './profile_field.vue'
import AddressProfileField from './profile_fields/address.vue'
import ProfileFields from './profile_fields.vue'
import Datepicker from './datepicker.vue'

Vue.use(TurbolinksAdapter)

jQuery(document).ready ->
  vue_apps = []

  Vue.component('vue-password-field-with-strength-meter', VuePasswordFieldWithStrengthMeter)
  for selector in ['#vue-change-password-app']
    vue_apps.push(new Vue({el: selector})) if jQuery(selector).count() > 0


  Vue.component("trash-icon", Trash2Icon)

  #Vue.component('datepicker', Datepicker)
  #for selector in ['#vue-datepicker-app']
  #  vue_apps.push(new Vue({el: selector, data: {de: de, en: en}})) if jQuery(selector).count() > 0

  Vue.component('editable', Editable)
  Vue.component('editable-property', EditableProperty)
  Vue.component('edit-box', EditBox)
  Vue.component('profile-field', ProfileField)
  Vue.component('address-profile-field', AddressProfileField)
  Vue.component('profile-fields', ProfileFields)
  Vue.component('datepicker', Datepicker)

  vue_apps.push(new Vue({el: "#vue-app"}))

# # As an alternative to `vue-turbolinks` we could save and restore
# # the html content of the vue components ourselves.
# #
# # This restoration is needed due to turbolinks caching. Otherwise,
# # the vue components cannot be initialized when loading a page from
# # the turbolinks cache.
# #
# # See also: https://github.com/turbolinks/turbolinks/wiki/VueJs-and-Turbolinks
# #
# store_vue_components_html = ->
#   jQuery('.vue-app').each ->
#     jQuery(this).data 'html-before-vue', jQuery(this)[0].outerHTML
#
# restore_vue_components_html = ->
#   jQuery('.vue-app').each ->
#     jQuery(this).replaceWith jQuery(this).data('html-before-vue')
