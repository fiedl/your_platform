<template lang="haml">
  %div.change_status
    %vue-auto-align-popup
      %button.btn.btn-white.dropdown-toggle{'@click': "toggle_dropdown"} Status ändern
      .dropdown-menu.dropdown-menu-card{':class': "dropdown_state"}
        .card
          .card-header
            %h3 Status von {{ user.first_name }} {{ user.last_name }} ändern
          .card-body
            .corporation.mb-3{'v-if': "corporations.length > 1"}
              %label.form-label.required Verbindung
              %select.form-select{'v-model': "corporation", '@change': "new_status = null"}
                %option{'v-for': "c in corporations", ':value': "c", ':key': "c.id"} {{ c.name }}

            .valid_from.mb-3
              %label.form-label.required Status-Änderung am
              %vue-datepicker{'v-model': "valid_from"}

            .new_status
              %label.form-label.required Neuer Status ab {{ valid_from }}
              %vue-status-select{':statuses': "corporation.statuses", 'v-model': "new_status", ':active_status_ids': "current_status_ids"}
          .card-footer
            .form-label.error.required{'v-if': "need_more_fields"} Bitte alle benötigten Felder ausfüllen
            .d-flex
              %a.btn.btn-link.text-muted{'@click': "toggle_dropdown"} Abbrechen
              .ml-auto.text-right
                %button.btn.btn-primary{':disabled': "! submission_enabled", '@click': "submit"} Bestätigen
                .error.mt-3{'v-if': "error"} {{ error }}
</template>

<script lang="coffee">
  moment = require('moment')
  Api = require('../api.coffee').default

  ChangeStatusButton =
    props: ['corporations', 'user', 'redirect_to_url', 'current_status_ids']
    data: ->
      dropdown_state: null
      corporation: @corporations[0]
      valid_from: moment().locale('de').format('L')
      new_status: null
      error: null
      submitting: false
    methods:
      toggle_dropdown: ->
        if @dropdown_state == "show"
          @dropdown_state = ""
        else
          @dropdown_state = "show"
      submit: ->
        component = this
        @submitting = true
        @error = null
        Api.post "/users/#{@user.id}/change_status", {
          data:
            corporation_id: @corporation.id
            status_id: @new_status.id
            valid_from: @valid_from
          error: (request, status, error)->
            component.error = request.responseText
            component.submitting = false
          success: (result)->
            window.location = component.redirect_to_url
        }
    computed:
      submission_enabled: ->
        (!@submitting) && (!@need_more_fields)
      need_more_fields: ->
        !(@corporation && @valid_from && @new_status)

  export default ChangeStatusButton
</script>

<style lang="sass">
  .change_status
    .card-header h3
      margin-bottom: 0

    .dropdown-menu
      position: relative
    .popup-alignment-right
      text-align: right
</style>