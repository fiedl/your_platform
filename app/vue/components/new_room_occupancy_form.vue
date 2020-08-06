<template lang="haml">
  .new_occupancy_from.card
    .card-body

      .current_occupant.mb-3
        %label.form-label Aktueller Bewohner
        .form-control-plaintext.align-items-center.d-flex
          %span.avatar.mr-2{'v-if': "room.occupant", ':style': "'background-image: url(' + room.occupant.avatar_path + ')'"}
          %span {{ (room.occupant && room.occupant.title) || 'Kein Bewohner' }}

      .row
        .valid_from.col-auto.mb-3
          %label.form-label.required Datum der Änderung
          %vue-datepicker{'v-model': "valid_from"}
        .valid_to.col-auto.mb-3{'v-if': "occupancy_type != 'empty'"}
          %label.form-label Auszugsdatum (optional)
          %vue-datepicker{'v-model': "valid_to"}

      .occupancy_type.mb-3
        %label.form-label Neuer Bewohner

        .btn-group
          %button.btn.btn-white{':class': "occupancy_type == 'empty' ? 'active': ''", '@click': "occupancy_type = 'empty'"}
            %i.fa.fa-ban
            Leerstand eintragen
          %button.btn.btn-white{':class': "occupancy_type == 'existing_user' ? 'active': ''", '@click': "occupancy_type = 'existing_user'"}
            %i.fa.fa-user
            Bestehende Person
          %button.btn.btn-white{':class': "occupancy_type == 'new_user' ? 'active': ''", '@click': "occupancy_type = 'new_user'"}
            %i.fa.fa-user-plus
            Neue Person

        .occupancy_type_empty{'v-if': "occupancy_type == 'empty'"}
          .text-muted.mt-2.mb-3 Ab {{ valid_from }} wird {{ room.name }} als leerstehend eingetragen.

        .occupancy_type_existing_user{'v-if': "occupancy_type == 'existing_user'"}
          .text-muted.mt-2.mb-3 Person als Bewohner eintragen, die bereits in der Datenbank hinterlegt ist.

          %fieldset.form-fieldset
            %label.form-label.required Bestehende Person
            %vue-user-select{'v-model': "existing_user", placeholder: "Bestehende Person auswählen", ':find_non_wingolf_users': "find_non_wingolf_users", ':find_deceased_users': "find_deceased_users"}

        .occupancy_type_new_user{'v-if': "occupancy_type == 'new_user'"}
          .text-muted.mt-2.mb-3 Neue Person als Bewohner eintragen, die noch nicht in der Datenbank hinterlegt ist. Die neue Person wird nur als Datensatz angelegt und erhält keinen Zugang zur Plattform, bis sie sich aktivmeldet.

          %fieldset.form-fieldset
            .first_name.mb-3
              %label.form-label.required Vorname
              %input.form-control{'v-model': "first_name", placeholder: "Vorname"}

            .last_name.mb-3
              %label.form-label.required Nachname
              %input.form-control{'v-model': "last_name", placeholder: "Nachname"}

            .date_of_birth.mb-3
              %label.form-label{':class': "is_historic_entry ? '' : 'required'"} Geburtsdatum
              %vue-datepicker{'v-model': "date_of_birth", placeholder: "Geburtsdatum"}

            .phone.mb-3
              %label.form-label{':class': "is_historic_entry ? '' : 'required'"} Handynummer
              %input.form-control{'v-model': "phone", placeholder: "Handynummer"}

            .email.mb-3
              %label.form-label E-Mail-Adresse
              %input.form-control{'v-model': "email", placeholder: "E-Mail-Adresse"}

            .study_address.mb-3
              %label.form-label{':class': "is_historic_entry ? '' : 'required'"} Studienanschrift
              .with_placeholder
                %textarea.form-control{'v-model': "study_address", rows: 3}
                .placeholder.text-muted{'v-if': "!study_address"}
                  Musterstraße 123
                  %br
                  12345 Musterstadt

            .home_address.mb-3
              %label.form-label{':class': "is_historic_entry ? '' : 'required'"} Heimatanschrift (Anschrift der Eltern)
              .with_placeholder
                %textarea.form-control{'v-model': "home_address", rows: 3}
                .placeholder.text-muted{'v-if': "!home_address"}
                  Musterstraße 123
                  %br
                  12345 Musterstadt

            .study.mb-3
              %label.form-label{':class': "is_historic_entry ? '' : 'required'"} Studienart
              %input.form-control{'v-model': "study", placeholder: "z.B. Bachelor-Studium"}

            .study_from.mb-3
              %label.form-label{':class': "is_historic_entry ? '' : 'required'"} Studienbeginn
              %input.form-control{'v-model': "study_from", placeholder: "z.B. WS 2020/21"}

            .university.mb-3
              %label.form-label{':class': "is_historic_entry ? '' : 'required'"} Universität
              %input.form-control{'v-model': "university", placeholder: "Name der Universität"}

            .subject.mb-3
              %label.form-label{':class': "is_historic_entry ? '' : 'required'"} Studienfach
              %input.form-control{'v-model': "subject", placeholder: "Studienfach"}

            .account_holder.mb-3
              %label.form-label Kontodaten für den Mieteinzug:
              %label.form-label Kontoinhaber
              %input.form-control{'v-model': "account_holder", placeholder: "Kontoinhaber"}

            .account_iban.mb-3
              %label.form-label{':class': "is_historic_entry ? '' : 'required'"} IBAN
              %input.form-control{'v-model': "account_iban", placeholder: "IBAN"}

            .account_bic.mb-3
              %label.form-label BIC
              %input.form-control{'v-model': "account_bic", placeholder: "BIC"}

            .privacy.mb-3
              %label.form-label.required Datenschutz
              %label.form-check
                %input.form-check-input{type: 'checkbox', 'v-model': "privacy"}
                %span.form-check-label Einwilligung zur Datenverarbeitung wurde erteilt

    .card-footer
      .d-flex
        %a.btn.btn-link.text-muted{':href': "redirect_to_url"} Abbrechen
        .ml-auto.text-right
          .form-label.error.required{'v-if': "need_more_fields"} Bitte alle benötigten Felder ausfüllen
          %button.btn.btn-primary{':disabled': "! submission_enabled", '@click': "submit"} Bestätigen
          .error.mt-3{'v-if': "error"} {{ error }}
</template>

<script lang="coffee">
  moment = require 'moment'
  Api = require('../api.coffee').default

  NewRoomOccupancyForm =
    props: ['url', 'room', 'default_study_address', 'default_date', 'redirect_to_url']
    data: ->
      valid_from: (this.default_date ||  moment().locale('de').format('L'))
      valid_to: null
      room_id: @room.id
      occupancy_type: 'empty'
      existing_user: null
      first_name: null
      last_name: null
      date_of_birth: null
      phone: null
      email: null
      study_address: @default_study_address
      home_address: null
      study: "Bachelor-Studium"
      study_from: null
      university: null
      subject: null
      account_holder: null
      account_iban: null
      account_bic: null
      privacy: null
      error: null
      submitting: false
    methods:
      submit: ->
        @error = null
        @submitting = true
        component = this
        Api.post "/room_occupancies", {
          data: {
            valid_from: @valid_from
            valid_to: @valid_to
            room_id: @room_id
            occupancy_type: @occupancy_type
            existing_user: @existing_user
            first_name: @first_name
            last_name: @last_name
            date_of_birth: @date_of_birth
            phone: @phone
            email: @email
            study_address: @study_address
            home_address: @home_address
            study: @study
            study_from: @study_from
            university: @university
            subject: @subject
            account_holder: @account_holder
            account_iban: @account_iban
            account_bic: @account_bic
            privacy: @privacy
          }
          error: (request, status, error)->
            component.error = request.responseText
            component.submitting = false
          success: ->
            window.location = component.redirect_to_url
        }
    computed:
      submission_enabled: ->
        !@submitting && @all_required_fields_are_given
      all_required_fields_are_given: ->
        console.log("historic", @is_historic_entry)
        if @occupancy_type == 'empty'
          @valid_from
        else if @occupancy_type == 'existing_user'
          @valid_from && @existing_user
        else if @occupancy_type == 'new_user'
          if @is_historic_entry
            @valid_from && @first_name && @last_name && @privacy
          else
            @valid_from && @first_name && @last_name && @date_of_birth && @phone && @study_address && @home_address && @study && @study_from && @university && @subject && @account_iban && @privacy
      need_more_fields: ->
        !@all_required_fields_are_given
      is_historic_entry: ->
        if @valid_from
          moment(@valid_from, 'DD.MM.YYYY').diff(moment(), 'years') <= -1
        else
          false
      find_non_wingolf_users: ->
        true
      find_deceased_users: ->
        @is_historic_entry
  export default NewRoomOccupancyForm
</script>

<style lang="sass">
  .with_placeholder
    position: relative
  .placeholder
    position: absolute
    top: 0
    padding: .4375rem .75rem
    pointer-events: none
  .error
    color: red
    font-size: 90%
    max-height: 10em
    overflow: scroll
</style>