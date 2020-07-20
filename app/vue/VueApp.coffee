# Make sure to run `bin/pack` after changing this file.
# Or keep `bin/webpack-dev-server` running.
# Otherwise, the changes are not picked up by the asset pipeline.

import Vue from 'vue'

# Third-party components
import { Trash2Icon } from 'vue-feather-icons'
import VueApexCharts from 'vue-apexcharts'

# Our own components
import PasswordField from './components/password_field.vue'
import Editable from './components/editable.vue'
import EditableProperty from './components/editable_property.vue'
import EditableImage from './components/editable_image.vue'
import EditBox from './components/edit_box.vue'
import ProfileField from './components/profile_field.vue'
import AddressProfileField from './components/profile_fields/address.vue'
import ProfileFields from './components/profile_fields.vue'
import Datepicker from './components/datepicker.vue'
import NumberOfMembersChart from './components/number_of_members_chart.vue'
import Leibfamilie from './components/leibfamilie.vue'
import UserSelect from './components/user_select.vue'
import ShowInEditMode from './components/show_in_edit_mode.vue'
import GroupMembersTable from './components/group_members_table.vue'
import AddGroupMemberForm from './components/add_group_member_form.vue'
import AutoAlignPopup from './components/auto_align_popup.vue'

jQuery(document).ready ->
  vue_apps = []

  # Third-party components
  Vue.component('vue-apexchart', VueApexCharts)
  Vue.component("vue-trash-icon", Trash2Icon)

  # Our own components
  Vue.component('vue-password-field', PasswordField)
  Vue.component('vue-editable', Editable)
  Vue.component('vue-editable-property', EditableProperty)
  Vue.component('vue-editable-image', EditableImage)
  Vue.component('vue-edit-box', EditBox)
  Vue.component('vue-profile-field', ProfileField)
  Vue.component('vue-address-profile-field', AddressProfileField)
  Vue.component('vue-profile-fields', ProfileFields)
  Vue.component('vue-datepicker', Datepicker)
  Vue.component('vue-number-of-members-chart', NumberOfMembersChart)
  Vue.component('vue-leibfamilie', Leibfamilie)
  Vue.component('vue-user-select', UserSelect)
  Vue.component('vue-show-in-edit-mode', ShowInEditMode)
  Vue.component('vue-group-members-table', GroupMembersTable)
  Vue.component('vue-add-group-member-form', AddGroupMemberForm)
  Vue.component('vue-auto-align-popup', AutoAlignPopup)

  vue_app = new Vue({el: "#vue-app"})
  vue_apps.push(vue_app)
  App.vue_app = vue_app
