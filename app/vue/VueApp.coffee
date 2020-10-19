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
import CouleurProfileField from './components/profile_fields/couleur.vue'
import ProfileFields from './components/profile_fields.vue'
import Datepicker from './components/datepicker.vue'
import NumberOfMembersChart from './components/number_of_members_chart.vue'
import Leibfamilie from './components/leibfamilie.vue'
import UserSelect from './components/user_select.vue'
import GroupSelect from './components/group_select.vue'
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
import NewDocumentsForm from './components/new_documents_form.vue'
import AktivmeldungPage from './components/aktivmeldung_page.vue'
import ChangeStatusButton from './components/change_status_button.vue'
import StatusSelect from './components/status_select.vue'
import SemesterCalendarAttachmentCard from './components/semester_calendar_attachment_card.vue'
import SemesterCalendarEvents from './components/semester_calendar_events.vue'
import Wysiwyg from './components/wysiwyg.vue'
import PublicWebsiteNavbarNav from './components/public_website_navbar_nav.vue'
import CreatePostForm from './components/create_post_form.vue'
import PostListGroup from './components/post_list_group.vue'
import Post from './components/post.vue'
import PostPage from './components/post_page.vue'
import Pictures from './components/pictures.vue'
import PagePictures from './components/page_pictures.vue'
import Calendar from './components/calendar.vue'
import OfficerCard from './components/officer_card.vue'
import Comments from './components/comments.vue'
import Attachments from './components/attachments.vue'
import AgeHistogramChart from './components/age_histogram_chart.vue'
import StatusPieChart from './components/status_pie_chart.vue'
import HeraldicColorSelect from './components/heraldic_color_select.vue'
import Ribbon from './components/ribbon.vue'
import NewEventForm from './components/new_event_form.vue'
import EventAttendees from './components/event_attendees.vue'
import RightCornerRibbon from './components/right_corner_ribbon.vue'

jQuery(document).ready ->
  vue_apps = []

  # Environment settings
  # Note: minimizing is done using the asset pipeline.
  if $('body').data('environment') == "production"
    Vue.config.devtools = false
    Vue.config.productionTip = false

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
  Vue.component('vue_profile_field', ProfileField)
  Vue.component('vue-address-profile-field', AddressProfileField)
  Vue.component('vue-couleur-profile-field', CouleurProfileField)
  Vue.component('vue-profile-fields', ProfileFields)
  Vue.component('vue-datepicker', Datepicker)
  Vue.component('vue-number-of-members-chart', NumberOfMembersChart)
  Vue.component('vue-leibfamilie', Leibfamilie)
  Vue.component('vue-user-select', UserSelect)
  Vue.component('vue-group-select', GroupSelect)
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
  Vue.component('vue_new_documents_form', NewDocumentsForm)
  Vue.component('vue_aktivmeldung_page', AktivmeldungPage)
  Vue.component('vue_change_status_button', ChangeStatusButton)
  Vue.component('vue_status_select', StatusSelect)
  Vue.component('vue-status-select', StatusSelect)
  Vue.component('vue_semester_calendar_attachment_card', SemesterCalendarAttachmentCard)
  Vue.component('vue_semester_calendar_events', SemesterCalendarEvents)
  Vue.component('vue_wysiwyg', Wysiwyg)
  Vue.component('vue-wysiwyg', Wysiwyg)
  Vue.component('vue_public_website_navbar_nav', PublicWebsiteNavbarNav)
  Vue.component('vue_create_post_form', CreatePostForm)
  Vue.component('vue-post-list-group', PostListGroup)
  Vue.component('vue_post_list_group', PostListGroup)
  Vue.component('vue-post', Post)
  Vue.component('vue_post', Post)
  Vue.component('vue-post-page', PostPage)
  Vue.component('vue_post_page', PostPage)
  Vue.component('vue-pictures', Pictures)
  Vue.component('vue_pictures', Pictures)
  Vue.component('vue_page_pictures', PagePictures)
  Vue.component('vue-page-pictures', PagePictures)
  Vue.component('vue-calendar', Calendar)
  Vue.component('vue_calendar', Calendar)
  Vue.component('vue-officer-card', OfficerCard)
  Vue.component('vue_officer_card', OfficerCard)
  Vue.component('vue-comments', Comments)
  Vue.component('vue_comments', Comments)
  Vue.component('vue_attachments', Attachments)
  Vue.component('vue-attachments', Attachments)
  Vue.component('vue_age_histogram_chart', AgeHistogramChart)
  Vue.component('vue_status_pie_chart', StatusPieChart)
  Vue.component('vue_heraldic_color_select', HeraldicColorSelect)
  Vue.component('vue-heraldic-color-select', HeraldicColorSelect)
  Vue.component('vue_ribbon', Ribbon)
  Vue.component('vue-ribbon', Ribbon)
  Vue.component('vue_new_event_form', NewEventForm)
  Vue.component('vue_event_attendees', EventAttendees)
  Vue.component('vue_right_corner_ribbon', RightCornerRibbon)

  vue_app = new Vue
    el: "#vue-app"
    methods:
      redirect_to: (url)->
        window.location = url

  vue_apps.push(vue_app)
  App.vue_app = vue_app
