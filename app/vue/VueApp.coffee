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
import CorporationsPage from './components/corporations_page.vue'
import EditableMembershipsTable from './components/editable_memberships_table.vue'
import EditableTags from './components/editable_tags.vue'
import Rooms from './components/rooms.vue'
import RoomHistory from './components/room_history.vue'
import Avatar from './components/avatar.vue'
import NewRoomOccupancyForm from './components/new_room_occupancy_form.vue'
import AccommodationSepaDebitForm from './components/accommodation_sepa_debit_form.vue'
import EditableSetting from './components/editable_setting.vue'
import AktivmeldungPage from './components/aktivmeldung_page.vue'
import ChangeStatusButton from './components/change_status_button.vue'
import StatusSelect from './components/status_select.vue'
import SemesterCalendarAttachmentCard from './components/semester_calendar_attachment_card.vue'
import SemesterCalendarEvents from './components/semester_calendar_events.vue'
import Wysiwyg from './components/wysiwyg.vue'
import PublicWebsiteNavbarNav from './components/public_website_navbar_nav.vue'

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
  Vue.component('vue_corporations_page', CorporationsPage)
  Vue.component('vue_editable_memberships_table', EditableMembershipsTable)
  Vue.component('vue_editable_tags', EditableTags)
  Vue.component('vue_rooms', Rooms)
  Vue.component('vue_room_history', RoomHistory)
  Vue.component('vue_avatar', Avatar)
  Vue.component('vue-avatar', Avatar)
  Vue.component('vue_new_room_occupancy_form', NewRoomOccupancyForm)
  Vue.component('vue_accommodation_sepa_debit_form', AccommodationSepaDebitForm)
  Vue.component('vue-editable-setting', EditableSetting)
  Vue.component('vue_editable_setting', EditableSetting)
  Vue.component('vue_aktivmeldung_page', AktivmeldungPage)
  Vue.component('vue_change_status_button', ChangeStatusButton)
  Vue.component('vue_status_select', StatusSelect)
  Vue.component('vue-status-select', StatusSelect)
  Vue.component('vue_semester_calendar_attachment_card', SemesterCalendarAttachmentCard)
  Vue.component('vue_semester_calendar_events', SemesterCalendarEvents)
  Vue.component('vue_wysiwyg', Wysiwyg)
  Vue.component('vue-wysiwyg', Wysiwyg)
  Vue.component('vue_public_website_navbar_nav', PublicWebsiteNavbarNav)

  vue_app = new Vue({el: "#vue-app"})
  vue_apps.push(vue_app)
  App.vue_app = vue_app
