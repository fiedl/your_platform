<template lang="haml">
  %div
    .page-header
      .row.align-itens-center
        .col-auto
          .page-title Verbindungen
        .col-auto.ml-auto.d-print-none
          %span.d-sm-inline
            .dropdown
              %button.dropdown-toggle.btn.btn-white{'data-toggle': "dropdown"}
                %span{'v-html': "preset_label(current_sort_preset)"}
              .dropdown-menu
                %a{class: "dropdown-item", 'v-for': "preset in sort_presets", '@click': "current_sort_preset = preset"}
                  %span{'v-html': "preset_label(preset)"}

    %transition-group{name: 'flip-list', tag: "div", class: "row row-deck row-cards"}
      .col-md-6.col-lg-4{'v-for': "corporation in sorted_corporations", ':key': "corporation.id"}
        -#.card.card-profile
        %a.card.card-profile{':href': "'/corporations/' + corporation.id"}
          %vue-editable-image{':src': "corporation.avatar_background_path", edit_alignment: "top right", ':editable': "corporation.editable", img_class: 'card-header', ':update_url': "corporation.update_path", attribute_name: "group[avatar_background]"}
          .card-body.text-center
            %vue-editable-image{':src': "corporation.avatar_path", img_class: "card-profile-img", ':editable': "corporation.editable", icon: "fa fa-group fa-2x", ':update_url': "corporation.update_path", attribute_name: 'group[avatar]'}
            %h3.mb-1= "{{ corporation.name }}"
            .col.text-muted.mb-3
              %small Aktive: {{ corporation.aktive_count }},
              %small Philister: {{ corporation.philister_count }}
            .avatar-list.avatar-list-stacked.mb-3
              %a.avatar{':style': "'background-image: url(' + officer.user.avatar_path + ')'", 'v-for': "officer in corporation.officers", ':title': "officer.user.title + ', ' + officer.description", ':href': "'/users/' + officer.user.id"}
            .mb-3.text-muted
              .phone{'v-if': "corporation.phone"}
                %small
                  %i.fa.fa-phone
                  %a.text-muted{':href': "'tel:' + corporation.phone"} {{ corporation.phone }}
              .email{'v-if': "corporation.email"}
                %small
                  %i.fa.fa-envelope
                  %a.text-muted{':href': "'mailto:' + corporation.email"} {{ corporation.email }}
          -#%a.card-btn{':href': "'/corporations/' + corporation.id"} Kontaktinformationen ansehen
</template>

<script lang="coffee">
  CorporationsPage =
    props: ['corporations']
    data: -> {
      sort_presets: [
        {name: "Alphabetisch", sort_by: "name", icon: 'fa fa-sort-alpha-asc'}
        {name: "Gründungsdatum", sort_by: "id", icon: 'fa fa-sort-numeric-asc'}
        {name: "Mitgliederzahl", sort_by: "members_count", icon: 'fa fa-sort-numeric-desc'}
      ]
      current_sort_preset: null
      current_corporations: []
    }
    created: ->
      this.current_sort_preset = this.sort_presets[0]
      this.current_corporations = this.corporations
      this.$root.$on 'search', this.search
    methods:
      preset_label: (preset)->
        @sort_icon(preset) + " " + preset.name
      sort_icon: (preset)->
        "<i class='#{preset.icon}'></i>"
      search: (query)->
        this.current_corporations = this.corporations.filter (corporation)->
          corporation.name.toLowerCase().includes query.toLowerCase()
    computed:
      sorted_corporations: ->
        if @current_sort_preset.sort_by == "name"
          @current_corporations.sort (a, b)-> (a.name > b.name) ? 1 : -1
        else if @current_sort_preset.sort_by == "id"
          @current_corporations.sort (a, b)-> (a.id > b.id) ? 1 : -1
        else if @current_sort_preset.sort_by == "members_count"
          @current_corporations.sort (a, b)-> (a.members_count < b.members_count) ? 1 : -1
  `export default CorporationsPage`
</script>

<style lang="sass">
  .flip-list-move
    transition: transform 1s
  .dropdown-menu a
    cursor: grab
</style>