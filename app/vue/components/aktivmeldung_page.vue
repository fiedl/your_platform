<template lang="haml">
  %div
    .page-header
      .page-title {{ page_title }}

    .card
      .card-body
        %label.form-label Verbindung
        %select.form-select{'v-model': "corporation"}
          %option{'v-for': "c in corporations", ':value': "c", ':key': "c.id"} {{ c.name }}

        %label.form-label.mt-3 {{ page_title }} zum Datum
        %vue-datepicker{'v-model': "valid_from"}

        .mt-5.mb-2
          .btn-group.d-none.d-sm-block
            %button.btn.btn-white{':class': "new_member_type == type ? 'active': ''", '@click': "new_member_type = type", 'v-for': "type in ['Aktivmeldung', 'Bandaufnahme', 'Hausbewohner', 'Keilgast', 'Dame']"} {{ type }}
          .btn-group-vertical.d-block.d-sm-none
            %button.btn.btn-white{':class': "new_member_type == type ? 'active': ''", '@click': "new_member_type = type", 'v-for': "type in ['Aktivmeldung', 'Bandaufnahme', 'Hausbewohner', 'Keilgast', 'Dame']"} {{ type }}

        .aktivmeldung_eintragen{'v-if': "new_member_type == 'Aktivmeldung'"}
          .text-muted Mit einer Aktivmeldung wird eine Person, die noch kein Wingolfit ist, in eine Verbindung aufgenommen.

        .bandaufnahme_eintragen{'v-if': "new_member_type == 'Bandaufnahme'"}
          .text-muted Mit einer Bandaufnahme erhält ein Wingolfit ein Band einer weiteren Verbindung.

          %fieldset.form-fieldset.mt-5
            %label.form-label.required Wingolfit, der das Band aufnimmt
            %vue-user-select{'v-model': "existing_user", placeholder: "Bundesbruder suchen und auswählen"}

            .status.mt-3
              %label.form-label.required Aufnahme in Status
              %select.form-select{'v-model': "status"}
                %option
                %option{'v-for': "s in corporation.statuses"} {{ s }}

        .hausbewohner_eintragen{'v-if': "new_member_type == 'Hausbewohner'"}
          .text-muted Neuen Hausbewohner in ein Zimmer eintragen. Der neue Hausbewohner wird in die Datenbank aufgenommen, erhält aber keinen Zugang zur Plattform.

          .zimmer.mt-5
            %label.form-label.required Zimmer
            %select.form-select{'v-model': "room"}
              %option
              %option{'v-for': "r in corporation.rooms", ':value': "r", ':key': "r.id"} {{ r.name }}
            .mt-2
              %a{':href': "'/corporations/' + corporation.id + '/accommodations'"} Zimmer verwalten

        .daten_neues_mitglied{'v-if': "['Hausbewohner', 'Aktivmeldung'].includes(new_member_type)"}
          %fieldset.form-fieldset.mt-5
            .first_name.mb-3
              %label.form-label.required Vorname
              %input.form-control{'v-model': "first_name", placeholder: "Vorname"}

            .last_name.mb-3
              %label.form-label.required Nachname
              %input.form-control{'v-model': "last_name", placeholder: "Nachname"}

            .date_of_birth.mb-3
              %label.form-label.required Geburtsdatum
              %vue-datepicker{'v-model': "date_of_birth", placeholder: "Geburtsdatum"}

            .phone.mb-3
              %label.form-label.required Handynummer
              %input.form-control{'v-model': "phone", placeholder: "Handynummer"}

            .email.mb-3
              %label.form-label{':class': "new_member_type == 'Aktivmeldung' ? 'required' : ''"} E-Mail-Adresse
              %input.form-control{'v-model': "email", placeholder: "E-Mail-Adresse"}

            .study_address.mb-3
              %label.form-label.required Studienanschrift
              .with_placeholder
                %textarea.form-control{'v-model': "study_address", rows: 3}
                .placeholder.text-muted{'v-if': "!study_address"}
                  Musterstraße 123
                  %br
                  12345 Musterstadt

            .home_address.mb-3
              %label.form-label.required Heimatanschrift (Anschrift der Eltern)
              .with_placeholder
                %textarea.form-control{'v-model': "home_address", rows: 3}
                .placeholder.text-muted{'v-if': "!home_address"}
                  Musterstraße 123
                  %br
                  12345 Musterstadt

            .study.mb-3
              %label.form-label.required Studienart
              %input.form-control{'v-model': "study", placeholder: "z.B. Bachelor-Studium"}

            .study_from.mb-3
              %label.form-label.required Studienbeginn
              %input.form-control{'v-model': "study_from", placeholder: "z.B. WS 2020/21"}

            .university.mb-3
              %label.form-label.required Universität
              %input.form-control{'v-model': "university", placeholder: "Name der Universität"}

            .subject.mb-3
              %label.form-label.required Studienfach
              %input.form-control{'v-model': "subject", placeholder: "Studienfach"}

            .account_holder.mb-3
              %label.form-label Kontodaten für den Miet- bzw. Getränke-Einzug:
              %label.form-label Kontoinhaber
              %input.form-control{'v-model': "account_holder", placeholder: "Kontoinhaber"}

            .account_iban.mb-3
              %label.form-label.required IBAN
              %input.form-control{'v-model': "account_iban", placeholder: "IBAN"}

            .account_bic.mb-3
              %label.form-label BIC
              %input.form-control{'v-model': "account_bic", placeholder: "BIC"}

            .leibbursch.mb-3{'v-if': "new_member_type == 'Aktivmeldung'"}
              %label.form-label Leibbursch (falls schon gewählt)
              %vue-user-select{'v-model': "leibbursch", placeholder: "Leibburschen suchen und auswählen"}

            .status.mb-3{'v-if': "['Aktivmeldung'].includes(new_member_type)"}
              %label.form-label.required Aufnahme in Status
              %select.form-select{'v-model': "status"}
                %option
                %option{'v-for': "s in corporation.statuses"} {{ s }}

            .privacy.mb-3
              %label.form-label.required Datenschutz
              %label.form-check
                %input.form-check-input{type: 'checkbox', 'v-model': "privacy"}
                %span.form-check-label Einwilligung zur Datenverarbeitung wurde erteilt

        .keilgast_eintragen{'v-if': "new_member_type == 'Keilgast'"}
          .text-muted Neuen Keilgast eintragen, der nicht auf dem Haus wohnt. Der neue Keilgast wird in die Datenbank aufgenommen, erhält aber keinen Zugang zur Plattform.

        .dame_eintragen{'v-if': "new_member_type == 'Dame'"}
          .text-muted Die neue Dame wird in die Datenbank aufgenommen, kann also z.B. über den Gäste-Verteiler erreicht werden, erhält aber keinen Zugang zur Plattform.

          .mt-5
            %label.form-check.form-check-inline
              %input.form-check-input{type: 'radio', 'v-model': "dame_type", value: "Aktiven-Dame"}
              %span.form-check-label Aktiven-Dame
            %label.form-check.form-check-inline
              %input.form-check-input{type: 'radio', 'v-model': "dame_type", value: "Philister-Gattin"}
              %span.form-check-label Philister-Gattin

        .daten_gaeste{'v-if': "['Keilgast', 'Dame'].includes(new_member_type)"}
          %fieldset.form-fieldset.mt-5
            .first_name.mb-3
              %label.form-label.required Vorname
              %input.form-control{'v-model': "first_name", placeholder: "Vorname"}

            .last_name.mb-3
              %label.form-label.required Nachname
              %input.form-control{'v-model': "last_name", placeholder: "Nachname"}

            .date_of_birth.mb-3
              %label.form-label Geburtsdatum
              %vue-datepicker{'v-model': "date_of_birth", placeholder: "Geburtsdatum"}

            .phone.mb-3
              %label.form-label Handynummer
              %input.form-control{'v-model': "phone", placeholder: "Handynummer"}

            .email.mb-3
              %label.form-label E-Mail-Adresse
              %input.form-control{'v-model': "email", placeholder: "E-Mail-Adresse"}

            .study_address.mb-3
              %label.form-label Anschrift
              .with_placeholder
                %textarea.form-control{'v-model': "address", rows: 3}
                .placeholder.text-muted{'v-if': "!address"}
                  Musterstraße 123
                  %br
                  12345 Musterstadt

            .university.mb-3
              %label.form-label Universität
              %input.form-control{'v-model': "university", placeholder: "Name der Universität"}

            .subject.mb-3
              %label.form-label Studienfach
              %input.form-control{'v-model': "subject", placeholder: "Studienfach"}

            .subject.mb-3
              %label.form-label Sonstige Notizen (z.B. Kontaktperson)
              %textarea.form-control{'v-model': "notes"}

            .privacy.mb-3
              %label.form-label.required Datenschutz
              %label.form-check
                %input.form-check-input{type: 'checkbox', 'v-model': "privacy"}
                %span.form-check-label Einwilligung zur Datenverarbeitung wurde erteilt

      .card-footer
        .d-flex
          %a.btn.btn-link.text-muted{'href': "/"} Abbrechen
          .ml-auto.text-right
            .form-label.error.required{'v-if': "need_more_fields"} Bitte alle benötigten Felder ausfüllen
            %button.btn.btn-primary{':disabled': "! submission_enabled", '@click': "submit"} Bestätigen
            .error.mt-3{'v-if': "error"} {{ error }}
</template>

<script lang="coffee">
  moment = require('moment')
  Api = require('../api.coffee').default

  AktivmeldungPage =
    props: ['corporations', 'initial_new_member_type', 'initial_existing_user']
    data: ->
      new_member_type: @initial_new_member_type || "Aktivmeldung"
      corporation: @corporations[0]
      valid_from: moment().locale('de').format('L')
      existing_user: @initial_existing_user || null
      first_name: null
      last_name: null
      date_of_birth: null
      phone: null
      email: null
      study_address: null
      home_address: null
      address: null
      study: "Bachelor-Studium"
      study_from: null
      university: null
      subject: null
      account_holder: null
      account_iban: null
      account_bic: null
      leibbursch: null
      notes: null
      room: {name: "", id: null}
      status: null
      dame_type: "Aktiven-Dame"
      privacy: null
      error: null
      submitting: false

    created: ->
      @study_address = @default_study_address

    methods:
      submit: ->
        @error = null
        @submitting = true
        component = this
        $.ajax
          method: 'post'
          url: "/aktivmeldungen",
          data: {
            new_member_type: @new_member_type
            corporation_id: @corporation.id
            valid_from: @valid_from
            existing_user_id: @existing_user && @existing_user.id
            first_name: @first_name
            last_name: @last_name
            date_of_birth: @date_of_birth
            phone: @phone
            email: @email
            study_address: @study_address
            home_address: @home_address
            address: @address
            study: @study
            study_from: @study_from
            university: @university
            subject: @subject
            account_holder: @account_holder
            account_iban: @account_iban
            account_bic: @account_bic
            leibbursch_id: @leibbursch && @leibbursch.id
            notes: @notes
            room_id: @room && @room.id
            dame_type: @dame_type
            status: @status
            privacy: @privacy
          }
          error: (request, status, error)->
            component.error = request.responseText
            component.submitting = false
          success: (data)->
            new_user = data.user
            window.location = "/users/#{new_user.id}"

    computed:
      page_title: ->
        "#{@new_member_type} eintragen"
      default_study_address: ->
        @corporation.postal_address if @corporation
      submission_enabled: ->
        !@submitting && @all_required_fields_are_given
      all_required_fields_are_given: ->
        if @new_member_type == "Aktivmeldung"
          @corporation && @valid_from && @first_name && @last_name && @date_of_birth && @phone && @email && @study_address && @home_address && @study && @study_from && @university && @subject && @account_iban && @status && @privacy
        else if @new_member_type == "Bandaufnahme"
          @corporation && @valid_from && @existing_user && @status
        else if @new_member_type == "Hausbewohner"
          @corporation && @valid_from && @first_name && @last_name && @date_of_birth && @phone && @study_address && @home_address && @study && @study_from && @university && @subject && @account_iban && @room && @privacy
        else if @new_member_type == "Keilgast"
          @corporation && @valid_from && @first_name && @last_name && @privacy
        else if @new_member_type == "Dame"
          @corporation && @valid_from && @first_name && @last_name && @privacy
      need_more_fields: ->
        !@all_required_fields_are_given


  export default AktivmeldungPage
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
