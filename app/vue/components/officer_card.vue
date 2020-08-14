<template lang="haml">
  .card
    .card-body
      %div{'v-if': "editing"}
        %h3.mb-0
          %vue-user-select{placeholder: "Amtsträger eintragen", 'v-model': "officers", ':multiple': "true"}
        .text-muted.text-h5.mt-2{':title': "office.scope.name"} {{ office.name }}
      %div{'v-else-if': "officers.length == 1"}
        .row.row-sm.align-items-center.mb-5
          .col-auto
            %vue-avatar{':user': "officer", class: "avatar-md"}
          .col
            %h3.mb-0
              %a{':href': "'/users/' + officer.id"} {{ officer.title }}
            .text-muted.text-h5{':title': "office.scope.name"}
              %span{'@click': "edit_office_name", 'v-if': "!editing_office_name"} {{ office.name }}
              %input{'v-else': true, 'v-model': "office.name", placeholder: "Bezeichnung des Amtes", '@blur': "submit_office_name", '@keydown.enter': "submit_office_name", '@keydown.esc': "cancel_edit_office_name", autofocus: true}
        .email{'v-if': "email"}
          %span{'v-html': "mail_icon"}
          %a.text-muted{':href': "'mailto:' + email", 'v-text': "email"}
        .phone{'v-if': "phone"}
          %span{'v-html': "phone_icon"}
          %a.text-muted{':href': "'tel:' + phone", 'v-text': "phone"}
      %div{'v-else': true}
        .row.row-sm
          .col-auto
            %vue-avatar.avatar-md{':group': "office"}
          .col
            %h3.mb-0{':title': "office.scope.name"}
              %span{'@click': "edit_office_name", 'v-if': "!editing_office_name"} {{ office.name }}
              %input{'v-else': true, 'v-model': "office.name", placeholder: "Bezeichnung des Amtes", '@blur': "submit_office_name", '@keydown.enter': "submit_office_name", '@keydown.esc': "cancel_edit_office_name", autofocus: true}
            .row.row-sm.align-items-center.mt-2{'v-for': "officer in officers", ':key': "officer.id"}
              .col-auto
                %vue-avatar.avatar-sm{':user': "officer"}
              .col
                %h4.mb-0
                  %a{':href': "'/users/' + officer.id"} {{ officer.title }}
            .text-muted.mt-3{'v-if': "officers.length == 0"} Amt derzeit nicht besetzt.
    .card-footer
      .btn-list{'v-if': "!editing"}
        %a.btn.btn-white.btn-sm{'@click': "navigate_to_history_path"} Historie
        %a.btn.btn-white.btn-sm{'v-if': "editable", '@click': "edit_officers", 'v-if': "!updating"} Amtsträger ändern
        %small.text-muted.mt-2.ml-1{'v-if': "updating"} Amtsträger ändern ...
        %i.fa.fa-check.text-success.mt-1.ml-1{'v-if': "success"}
      .d-flex{'v-else': true}
        %a.btn.btn-link.text-muted{'@click': "cancel_edit_officers"} Abbrechen
        .ml-auto.text-right
          %a.btn.btn-primary.text-white{'@click': "submit_new_officers"} Bestätigen
      .error.mt-3.text-danger{'v-if': "error"} {{ error.first(100) }}

</template>

<script lang="coffee">
  Api = require('../api.coffee').default

  OfficerCard =
    props: ['initial_office', 'initial_officers', 'history_path', 'editable', 'can_rename_office', 'mail_icon', 'phone_icon']
    data: ->
      office: @initial_office
      officers: @initial_officers
      officers_before_editing: []
      editing: false
      editing_office_name: false
      office_name_before_editing: null
      updating: false
      error: null
      success: false
    methods:
      edit_office_name: ->
        if @can_rename_office
          @editing_office_name = true
          @office_name_before_editing = @office.name
      cancel_edit_office_name: ->
        @office.name = @office_name_before_editing
        @editing_office_name = false
      submit_office_name: ->
        component = this
        @editing_office_name = false
        Api.put "/offices/#{@office.id}",
          data:
            office: @office
          error: (request, status, error)->
            component.error = request.responseText
          success: ->
            component.success = true
      edit_officers: ->
        @success = false
        @error = false
        @editing = true
        @officers_before_editing = @officers
      cancel_edit_officers: ->
        @officers = @officers_before_editing
        @editing = false
      submit_new_officers: ->
        @editing = false
        @success = false
        @updating = true
        component = this
        Api.put "/offices/#{@office.id}",
          data:
            officer_ids: (@officers.map (officer) -> officer.id)
          error: (request, status, error)->
            component.error = request.responseText
            component.updating = false
          success: ->
            component.success = true
            component.updating = false
      navigate_to_history_path: ->
        window.location = @history_path
    computed:
      officer: ->
        @officers[0]
      email: ->
        @office.email || @officer.email
      phone: ->
        @officer.phone

  export default OfficerCard
</script>