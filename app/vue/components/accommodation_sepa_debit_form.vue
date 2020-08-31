<template lang="haml">
  %div
    .card
      %div
        %table.table.card-table.table-vcenter.table-mobile-sm
          %thead
            %tr
              %th
              %th Konto
              %th Betrag
              %th Verwendungszweck
              %th Mandatsreferenz
              %th Mandat unterschrieben am
          %tbody
            %tr{'v-for': "room in rooms", 'v-if': "room.occupant && room.occupant.bank_account && room.occupant.bank_account.iban"}
              %td.w-1
                %vue-avatar{':url': "room.occupant.avatar_path"}
              %td
                %div
                  %a{':href': "'/users/' + room.occupant.id"} {{ room.occupant.bank_account.account_holder }}
                %div
                  %small.text-muted
                    IBAN:
                    %span {{ room.occupant.bank_account.iban }}
                %div
                  %small.text-muted
                    BIC:
                    %span {{ room.occupant.bank_account.bic }}
              %td
                %vue-editable{':initial-value': "room.rent", ':url': "'/api/v1/corporations/' + corporation.id + '/rooms/' + room.id", paramKey: "room[rent]", ':editable': "true", type: 'number'}
                €
              %td {{ complete_subject(room) }}
              %td
                .d-sm.d-md-none.text-muted Mandatsreferenz:
                %vue-editable-setting{type: 'text', ':setting': "room.occupant.mandate_id_setting", placeholder: "K-02-2011-12345"}
              %td
                .d-sm.d-md-none.text-muted Mandat unterschrieben am:
                %vue-editable-setting{type: 'date', ':setting': "room.occupant.mandate_date_setting"}
            %tr{'v-for': "room in rooms", 'v-if': "room.occupant && !(room.occupant.bank_account && room.occupant.bank_account.iban)"}
              %td.w-1
                %vue-avatar{':url': "room.occupant.avatar_path"}
              %td.error{colspan: 5}
                Für {{ room.occupant.title }} ist kein Konto hinterlegt.
                %a{':href': "'/users/' + room.occupant.id"} Konto eintragen

      .card-body.mt-3
        %label.form-label Verwendungszweck anpassen
        %input.form-control{'v-model': "subject", name: "subject"}

        %label.mt-3.form-label.required Gläubiger-Identifikationsnummer
        %input.form-control{':value': "creditor_identifier", name: "creditor_identifier", placeholder: "DE98ZZZ09999999999"}

      .card-footer
        .d-flex
          %a.btn.btn-link.text-muted{':href': "return_url"} Abbrechen
          %button.btn.btn-primary.ml-auto{type: 'submit'} Lastschrift-XML generieren

</template>

<script lang="coffee">
  AccommodationSepaDebitForm =
    props: ['rooms', 'corporation', 'return_url', 'creditor_identifier']
    data: ->
      subject: "Mieteinzug #{@corporation.name}"
    created: ->
      $(document).on 'keypress', '#sepa_debit_form', (e)->
        e.preventDefault() if (e.charCode || e.keyCode) == 13 # enter
    methods:
      complete_subject: (room)->
        "#{@subject} #{room.name}"

  export default AccommodationSepaDebitForm
</script>

<style lang="sass">
  td.error
    color: red
  .table-responsive
    overflow-y: hidden
</style>